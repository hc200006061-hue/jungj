import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'package_data.dart';

// ==========================================
// [유틸리티 및 데이터 모델]
// ==========================================

String normalizeKanji(dynamic raw) {
  String k = (raw ?? '').toString().trim();
  if (k.isEmpty || k == '(빈칸)') return '';
  if (k.length >= 2 && k.startsWith('[') && k.endsWith(']')) {
    k = k.substring(1, k.length - 1).trim();
  }
  return k;
}

class Word {
  String kr;
  String jp;
  String kanji;
  String hiragana;
  String packageId;
  int correctCount;

  Word({
    required this.kr,
    required this.jp,
    this.kanji = '',
    this.hiragana = '',
    this.packageId = '',
    this.correctCount = 0,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      kr: json['kr'] ?? '',
      jp: (json['jp'] ?? '').toString().replaceAll('-', ''),
      kanji: json['kanji'] ?? '',
      hiragana: json['hiragana'] ?? '',
      packageId: json['packageId'] ?? '',
      correctCount: json['correctCount'] ?? 0,
    );
  }

  factory Word.fromPackageEntry(Map<String, dynamic> w, String packageId) {
    return Word(
      kr: w['한국어'] ?? '',
      jp: w['일본어발음'] ?? '',
      kanji: normalizeKanji(w['한자']),
      hiragana: (w['히라가나'] ?? '').toString(),
      packageId: packageId,
    );
  }

  Word copy() => Word(
    kr: kr,
    jp: jp,
    kanji: kanji,
    hiragana: hiragana,
    packageId: packageId,
    correctCount: correctCount,
  );

  Map<String, dynamic> toJson() {
    return {
      'kr': kr,
      'jp': jp,
      'kanji': kanji,
      'hiragana': hiragana,
      'packageId': packageId,
      'correctCount': correctCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word && kr == other.kr && jp == other.jp;

  @override
  int get hashCode => kr.hashCode ^ jp.hashCode;
}

// ==========================================
// [앱 상태 관리자]
// ==========================================

class AppStateManager extends ChangeNotifier {
  static final AppStateManager instance = AppStateManager._internal();
  AppStateManager._internal();

  List<Word> allWords = [];
  List<Word> unknownWords = [];
  List<Word> completedWords = [];

  Set<String> unlockedPackageIds = Set.from(starterPackages.map((p) => p.docId));
  String? priorityLevel;
  bool isTutorialCompleted = false;
  bool hasAllPackages = false;
  bool isDarkMode = false;
  String quizDisplayField = 'both';

  Map<String, List<Word>> packageCache = {};

  void clearUserData() {
    allWords.clear();
    unknownWords.clear();
    completedWords.clear();
    unlockedPackageIds = Set.from(starterPackages.map((p) => p.docId));
    priorityLevel = null;
    isTutorialCompleted = false;
    hasAllPackages = false;
    isDarkMode = false;
    quizDisplayField = 'both';
    packageCache.clear();
    notifyListeners();
  }

  bool isLevelCompleted(String level) {
    final pkgs = packagesForLevel(level);
    if (pkgs.isEmpty) return false;
    return pkgs.every((p) => isPackageCompleted(p));
  }

  bool isLevelInProgress(String level) {
    if (isLevelCompleted(level)) return false;
    return packagesForLevel(level).any((p) => isPackageInProgress(p));
  }

  bool isPackageCompleted(PackageInfo pkg) {
    final int inAll = allWords.where((w) => w.packageId == pkg.docId).length;
    final int inComp = completedWords.where((w) => w.packageId == pkg.docId).length;
    return (inAll + inComp) >= pkg.count && inAll == 0;
  }

  bool isPackageInProgress(PackageInfo pkg) {
    if (isPackageCompleted(pkg)) return false;
    final int inAll = allWords.where((w) => w.packageId == pkg.docId).length;
    final int inComp = completedWords.where((w) => w.packageId == pkg.docId).length;
    return (inAll + inComp) > 0;
  }

  PackageInfo? get nextPackageToUnlock {
    if (priorityLevel != null) {
      final withinLevel = packagesForLevel(priorityLevel!)
          .where((p) => !isPackageCompleted(p))
          .toList();
      if (withinLevel.isNotEmpty) {
        withinLevel.sort((a, b) => a.order.compareTo(b.order));
        return withinLevel.first;
      }
    }
    for (final p in packageOrder) {
      if (!isPackageCompleted(p)) return p;
    }
    return null;
  }

  bool isPackageUnlocked(PackageInfo p) =>
      hasAllPackages || unlockedPackageIds.contains(p.docId);

  bool isLevelStarted(String level) =>
      packagesForLevel(level).any((p) => isPackageUnlocked(p) || isPackageInProgress(p));

  // [미결제 시 완료단어 존재하면 더 이상 보충하지 않는 단어 자동 채움 로직]
  Future<void> refillWordsIfNeeded() async {
    // 미결제 사용자가 마스터(완료)한 단어가 1개라도 있다면 다음 단어를 미리 보충하지 않음
    if (!hasAllPackages && completedWords.isNotEmpty) {
      return;
    }

    List<PackageInfo> targetPackages = [];
    
    if (priorityLevel != null) {
      targetPackages.addAll(packagesForLevel(priorityLevel!));
      final validDocIds = targetPackages.map((p) => p.docId).toSet();
      allWords.removeWhere((w) => !validDocIds.contains(w.packageId));
    } else {
      for (final p in packageOrder) {
        if (!targetPackages.contains(p)) {
          targetPackages.add(p);
        }
      }
    }

    for (final pkg in targetPackages) {
      if (allWords.length >= 50) break;
      if (isPackageCompleted(pkg)) continue;

      if (!isPackageUnlocked(pkg)) {
        break;
      }

      List<Word> packageWords = [];
      if (packageCache.containsKey(pkg.docId)) {
        packageWords = packageCache[pkg.docId]!;
      } else {
        try {
          final doc = await FirebaseFirestore.instance.collection('words').doc(pkg.docId).get();
          if (doc.exists) {
            final wordsData = (doc.data()?['wordsList'] as List?) ?? [];
            packageWords = wordsData.map((w) => Word.fromPackageEntry(w, pkg.docId)).toList();
            packageCache[pkg.docId] = packageWords.map((w) => w.copy()).toList();
          }
        } catch (e) {
          debugPrint('단어 가져오기 실패: $e');
          break;
        }
      }

      if (packageWords.isEmpty) continue;

      final remainingWords = packageWords.where((w) {
        bool inAll = allWords.any((aw) => aw.kr == w.kr && aw.jp == w.jp);
        bool inComp = completedWords.any((cw) => cw.kr == w.kr && cw.jp == w.jp);
        return !inAll && !inComp;
      }).toList();

      if (remainingWords.isEmpty) {
        continue;
      }

      int needed = 50 - allWords.length;
      int takeCount = remainingWords.length < needed ? remainingWords.length : needed;

      for (int i = 0; i < takeCount; i++) {
        allWords.add(remainingWords[i].copy());
      }
    }

    await saveUserData();
    notifyListeners();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        
        hasAllPackages = data['hasAllPackages'] ?? false;
        final rawUnlocked = data['unlockedPackageIds'];
        if (rawUnlocked is List) {
          unlockedPackageIds = rawUnlocked.map((e) => e.toString()).toSet();
        } else {
          unlockedPackageIds = {};
        }
        unlockedPackageIds.addAll(starterPackages.map((p) => p.docId));
        if (hasAllPackages) {
          unlockedPackageIds.addAll(packageOrder.map((p) => p.docId));
        }

        priorityLevel = data['priorityLevel'];
        isTutorialCompleted = data['tutorialCompleted'] ?? false;
        isDarkMode = data['isDarkMode'] ?? false;
        quizDisplayField = data['quizDisplayField'] ?? 'both';

        final wordsDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('user_words').doc('words_doc').get();
        if (wordsDoc.exists) {
          final wordsData = wordsDoc.data() ?? {};
          final rawAll = wordsData['allWords'] as List?;
          final rawUnknown = wordsData['unknownWords'] as List?;
          final rawCompleted = wordsData['completedWords'] as List?;

          allWords = rawAll?.map((e) => Word.fromJson(Map<String, dynamic>.from(e))).toList() ?? [];
          unknownWords = rawUnknown?.map((e) => Word.fromJson(Map<String, dynamic>.from(e))).toList() ?? [];
          completedWords = rawCompleted?.map((e) => Word.fromJson(Map<String, dynamic>.from(e))).toList() ?? [];
        }
      } else {
        await resetUserData();
      }
    } catch (e) {
      debugPrint('사용자 데이터 로드 실패: $e');
    }

    await refillWordsIfNeeded();
    themeModeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> resetUserData() async {
    String targetDocId = starterPackage.docId;
    if (priorityLevel != null) {
      final starter = starterPackages.firstWhere((p) => p.level == priorityLevel, orElse: () => starterPackage);
      targetDocId = starter.docId;
    }

    try {
      if (packageCache.containsKey(targetDocId)) {
        allWords = packageCache[targetDocId]!.map((w) => w.copy()).toList();
      } else {
        final basicDoc = await FirebaseFirestore.instance.collection('words').doc(targetDocId).get();
        if (basicDoc.exists) {
          final wordsData = (basicDoc.data()?['wordsList'] as List?) ?? [];
          allWords = wordsData.map((e) => Word.fromPackageEntry(e, targetDocId)).toList();
          packageCache[targetDocId] = allWords.map((w) => w.copy()).toList();
        }
      }
    } catch (e) {
      debugPrint('기본 단어 불러오기 실패: $e');
      allWords = [];
    }

    unknownWords = [];
    completedWords = [];

    unlockedPackageIds = Set.from(starterPackages.map((p) => p.docId));
    if (hasAllPackages) {
      unlockedPackageIds.addAll(packageOrder.map((p) => p.docId));
    }

    await saveUserData();
    notifyListeners();
  }

  Future<void> saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    batch.set(userRef, {
      'unlockedPackageIds': unlockedPackageIds.toList(),
      'priorityLevel': priorityLevel,
      'tutorialCompleted': isTutorialCompleted,
      'hasAllPackages': hasAllPackages,
      'isDarkMode': isDarkMode,
      'quizDisplayField': quizDisplayField,
    }, SetOptions(merge: true));

    final wordsRef = userRef.collection('user_words').doc('words_doc');
    batch.set(wordsRef, {
      'allWords': allWords.map((w) => w.toJson()).toList(),
      'unknownWords': unknownWords.map((w) => w.toJson()).toList(),
      'completedWords': completedWords.map((w) => w.toJson()).toList(),
    });

    await batch.commit();
  }
}

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

// ==========================================
// [앱 진입점]
// ==========================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

Color primaryTextColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
Color secondaryTextColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;

Color cardSurfaceColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1B2A55) : const Color(0xFFEBE3D5);

const Map<String, List<Color>> levelGradientColors = {
  'N5': [Color(0xFF34D399), Color(0xFF059669)],
  'N4': [Color(0xFF38BDF8), Color(0xFF0284C7)],
  'N3': [Color(0xFF818CF8), Color(0xFF4F46E5)],
  'N2': [Color(0xFFC084FC), Color(0xFF9333EA)],
  'N1': [Color(0xFFFB923C), Color(0xFFDC2626)],
};

LinearGradient levelGradient(String level) {
  final colors = levelGradientColors[level] ?? [Colors.grey.shade400, Colors.grey.shade700];
  return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors);
}

LinearGradient screenBackgroundGradient(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: dark
        ? [const Color(0xFF0F1B3C), const Color(0xFF16224A)]
        : [const Color(0xFFFDF6EC), const Color(0xFFF3E9D8)],
  );
}

String? packageStatusLabel(PackageInfo pkg) {
  final state = AppStateManager.instance;
  if (state.isPackageCompleted(pkg)) return '완료함';
  if (state.isPackageInProgress(pkg)) return '진행중';
  return null;
}

String? levelStatusLabel(String level) {
  final state = AppStateManager.instance;
  if (state.isLevelCompleted(level)) return '완료함';
  if (state.isLevelInProgress(level)) return '진행중';
  return null;
}

Widget statusBadge(String? label) {
  if (label == null) return const SizedBox.shrink();
  final bool isCompleted = label == '완료함';
  final Color color = isCompleted ? const Color(0xFF2563EB) : const Color(0xFF16A34A);
  final Color bg = isCompleted ? const Color(0xFFDCEAFE) : const Color(0xFFDCF7E3);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5DC),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown, brightness: Brightness.light),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F1B3C),
            cardColor: const Color(0xFF1B2A55),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ==========================================
// [스플래시 화면]
// ==========================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/images/logo.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder(
            future: AppStateManager.instance.loadUserData(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return const HomeScreen();
            },
          );
        }
        return const LoginScreen();
      },
    );
  }
}

// ==========================================
// [로그인 / 회원가입 화면]
// ==========================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _login() async {
    if (!_isValidEmail(_email.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이메일 형식이 올바르지 않습니다.')));
      return;
    }
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호는 6자리 이상이어야 합니다.')));
      return;
    }

    setState(() { _isLoading = true; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on FirebaseAuthException catch (e) {
      String message = '로그인 실패';
      if (e.code == 'user-not-found') {
        message = '존재하지 않는 계정입니다. 회원가입을 진행해주세요.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = '비밀번호가 올바르지 않습니다.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _signUp() async {
    if (!_isValidEmail(_email.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이메일 형식이 올바르지 않습니다.')));
      return;
    }
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호는 6자리 이상이어야 합니다.')));
      return;
    }

    setState(() { _isLoading = true; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다.')));
      }
    } on FirebaseAuthException catch (e) {
      String message = '회원가입 실패';
      if (e.code == 'email-already-in-use') {
        message = '이미 가입된 이메일입니다. 로그인해주세요.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: '이메일')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: '비밀번호 (6자리 이상)'), obscureText: true),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton(onPressed: _login, child: const Text('로그인')),
              const SizedBox(height: 8),
              TextButton(onPressed: _signUp, child: const Text('새 계정으로 회원가입')),
            ]
          ],
        ),
      ),
    );
  }
}

// ==========================================
// [메인 홈 화면]
// ==========================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final ConfettiController _confettiController;
  bool _isPurchasing = false;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static const String _allPackagesProductId = 'all_packages_unlocked_9900';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    if (!kIsWeb) {
      try {
        final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
        purchaseUpdated.listen((purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        }, onDone: () {}, onError: (error) {
          debugPrint('결제 에러: $error');
        });
      } catch (e) {
        debugPrint('InAppPurchase 스트림 바인딩 실패: $e');
      }
    }

    if (!AppStateManager.instance.isTutorialCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showManualDialog(isFirstTime: true);
      });
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() { _isPurchasing = true; });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('결제 에러: ${purchaseDetails.error?.message}')));
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _verifyAndDeliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        if (mounted) setState(() { _isPurchasing = false; });
      }
    }
  }

  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    final state = AppStateManager.instance;
    state.hasAllPackages = true;
    state.unlockedPackageIds.addAll(packageOrder.map((p) => p.docId));
    await state.refillWordsIfNeeded();
    await state.saveUserData();

    _confettiController.play();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전체 패키지 결제가 승인되었습니다! 모든 단어가 해제되었습니다.')),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showManualDialog({bool isFirstTime = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isFirstTime,
      builder: (context) => AlertDialog(
        title: const Text('핵심 학습 가이드', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            '1. 망각곡선 기반 자동 단어 공급 시스템\n'
            '• 학습 단어장은 언제나 최대 50개의 단어로 유지됩니다.\n'
            '• 단어를 암기하여 완료 처리되면, 부족한 개수만큼 다음 단어 패키지에서 자동으로 새로운 단어가 채워집니다.\n\n'
            '2. 암기 완성 (마스터) 조건\n'
            '• 한 번에 정답을 맞춘 단어는 정답 카운트가 1회 누적됩니다.\n'
            '• 단어당 누적 정답 횟수 5회를 달성하면 완전히 암기한 것으로 간주되어 학습 목록에서 제외되고 완료 목록으로 이동합니다.\n\n'
            '3. 오답 처리 및 복습 시스템\n'
            '• 오답을 제출하더라도 기존 누적 정답 카운트는 차감되거나 초기화되지 않고 유지됩니다.\n'
            '• 오답 단어는 학습 목록에 계속 남아 재시험을 통해 맞출 때까지 지속적으로 출제됩니다.\n\n'
            '4. 맞춤형 시험 모드 설정\n'
            '• 시험 화면 상단의 [시험모드변경] 버튼을 통해 문제 표시 방식을 변경할 수 있습니다.\n'
            '  - 뜻 + 한자 함께 보기\n'
            '  - 뜻만 보기\n'
            '  - 한자만 보기',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isFirstTime) {
                AppStateManager.instance.isTutorialCompleted = true;
                AppStateManager.instance.saveUserData();
              }
            },
            child: const Text('확인', style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('진행사항 초기화', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('학습한 데이터를 삭제하고 재학습하시겠습니까? (결제한 기록은 유지됩니다)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니요', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AppStateManager.instance.resetUserData();
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('학습 데이터가 초기화되었습니다.')));
              }
            },
            child: const Text('네', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigate(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    setState(() {});
  }

  // [수정된 결제 여부 검사 로직]
  bool _checkAndShowPurchaseIfNeeded(BuildContext context) {
    final state = AppStateManager.instance;

    // 미결제 상태이고 완료된 단어가 1개 이상 생기면 다음 시험 진입 시 결제창 출력
    if (!state.hasAllPackages && state.completedWords.isNotEmpty) {
      final nextPkg = state.nextPackageToUnlock ?? starterPackage;
      _showRequiredPurchaseDialog(nextPkg);
      return false;
    }

    if (state.allWords.isNotEmpty) {
      return true;
    }

    final nextPkg = state.nextPackageToUnlock;
    if (nextPkg != null && !state.isPackageUnlocked(nextPkg)) {
      _showRequiredPurchaseDialog(nextPkg);
      return false;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('모든 단어장의 학습을 완료하셨습니다!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
      ),
    );
    return false;
  }

  void _startQuiz() async {
    final state = AppStateManager.instance;
    await state.refillWordsIfNeeded();
    
    if (!_checkAndShowPurchaseIfNeeded(context)) return;

    _navigate(const QuizScreen(quizType: 'random'));
  }

  void _openLevel(String level) async {
    final state = AppStateManager.instance;
    if (state.priorityLevel != level) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('학습 전환', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('$level 급수를 학습하시겠습니까?', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      );

      if (confirm == true) {
        state.priorityLevel = level;
        state.allWords.clear();
        await state.refillWordsIfNeeded();
        await state.saveUserData();
        setState(() {});
      }
    }
    if (!mounted) return;
    _navigate(PackageLevelScreen(level: level));
  }

  void _showRequiredPurchaseDialog(PackageInfo requiredPackage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('잠금 해제 필요', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '무료 제공 단어를 모두 학습하셨습니다.\n다음 단어장(${requiredPackage.displayName})을 계속 학습하려면 결제가 필요합니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple.shade200, Colors.deepPurple.shade300]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text('전체 급수 (N5 ~ N1 총 7,573개 단어)\n영구 무료해제', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('9,900원', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 42)),
                    onPressed: () {
                      Navigator.pop(context);
                      _triggerInAppPurchase();
                    },
                    child: const Text('9,900원 결제하기', style: TextStyle(fontSize: 15, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기', style: TextStyle(fontSize: 16, color: Colors.grey))),
        ],
      ),
    );
  }

  void _showAllPackagesPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 단어 해제', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple.shade200, Colors.deepPurple.shade300]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text('전체 급수 (N5 ~ N1 총 7,573개 단어)\n영구 무료해제', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    const Text('9,900원', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 45)),
                      onPressed: () {
                        Navigator.pop(context);
                        _triggerInAppPurchase();
                      },
                      child: const Text('9,900원 결제하기', style: TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기', style: TextStyle(fontSize: 16, color: Colors.grey))),
        ],
      ),
    );
  }

  void _triggerInAppPurchase() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('웹 버전에서는 결제를 지원하지 않습니다. 앱을 이용해 주세요.')),
        );
      }
      return;
    }

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('스토어 결제 서비스를 이용할 수 없습니다.')));
        }
        return;
      }

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({_allPackagesProductId});

      if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('등록된 결제 상품 정보를 찾을 수 없습니다.')));
        }
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('결제 요청 중 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('결제 서비스를 실행할 수 없습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateManager.instance;
    final TextStyle uniformTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: primaryTextColor(context),
    );

    final TextStyle uniformSubTitleStyle = TextStyle(
      fontSize: 12,
      color: secondaryTextColor(context),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => _showManualDialog(isFirstTime: false),
          child: Text('설명서', style: TextStyle(color: primaryTextColor(context), fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        actions: [
          IconButton(
            tooltip: '진행사항 초기화',
            icon: Icon(Icons.restore, color: primaryTextColor(context)),
            onPressed: _confirmResetData,
          ),
          IconButton(
            tooltip: '다크모드',
            icon: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: primaryTextColor(context)),
            onPressed: () {
              setState(() {
                state.isDarkMode = !state.isDarkMode;
                themeModeNotifier.value = state.isDarkMode ? ThemeMode.dark : ThemeMode.light;
                state.saveUserData();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: primaryTextColor(context)),
            onPressed: () {
              AppStateManager.instance.clearUserData();
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: screenBackgroundGradient(context))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30),

                    _GradientActionButton(
                      label: '시험보기',
                      icon: Icons.edit_note,
                      gradientColors: const [Color(0xFF34D399), Color(0xFF059669)],
                      onTap: _startQuiz,
                    ),
                    const SizedBox(height: 25),

                    ...levelOrder.map((level) {
                      final bool started = state.isLevelStarted(level);
                      final String? status = levelStatusLabel(level);
                      final int total = totalWordCountForLevel(level);

                      return Container(
                        width: 300,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: cardSurfaceColor(context),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openLevel(level),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      _LevelBadge(level: level, text: '', size: 44),
                                      const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(level, style: uniformTitleStyle),
                                        Text(started ? '$total개 단어' : '$total개 단어 · 시작 전', style: uniformSubTitleStyle),
                                      ],
                                    ),
                                  ),
                                  statusBadge(status),
                                  const SizedBox(width: 4),
                                  Icon(Icons.chevron_right, color: secondaryTextColor(context)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    if (!state.hasAllPackages) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _isPurchasing ? null : _showAllPackagesPurchaseDialog,
                        icon: const Icon(Icons.workspace_premium, size: 18),
                        label: const Text('전체 단어 한 번에 해제하기'),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Text('현재 ${state.completedWords.length}개의 단어를 마스터하셨습니다!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: secondaryTextColor(context))),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple],
            ),
          ),
          if (_isPurchasing)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  final String text;
  final double size;
  const _LevelBadge({required this.level, required this.text, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: levelGradient(level),
        boxShadow: [BoxShadow(color: (levelGradientColors[level]?.last ?? Colors.grey).withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: size * 0.34),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  const _GradientActionButton({required this.label, required this.icon, required this.gradientColors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: 260,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors, begin: Alignment.centerLeft, end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: gradientColors.last.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// [퀴즈 화면]
// ==========================================

class QuizScreen extends StatefulWidget {
  final String quizType;
  final List<Word>? customWords;

  const QuizScreen({super.key, required this.quizType, this.customWords});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Word> _currentQuizData = [];
  final List<Word> _currentSessionIncorrect = [];
  final List<Word> _masteredThisSession = [];
  int _currentIndex = 0;
  bool _isFirstTry = true;
  bool _showError = false;
  bool _showCheckmark = false;
  bool _isProcessingAnswer = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startQuizData();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    AppStateManager.instance.saveUserData();
    _textController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startQuizData() {
    final state = AppStateManager.instance;
    if (widget.quizType == 'random') {
      _currentQuizData = List.from(state.allWords)..shuffle();
      _currentQuizData = _currentQuizData.take(20).toList();
    } else if (widget.quizType == 'retry' && widget.customWords != null) {
      _currentQuizData = List.from(widget.customWords!);
    }
  }

  void _showQuizModeDialog() {
    final state = AppStateManager.instance;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('시험모드 변경', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('표시 항목', style: TextStyle(fontWeight: FontWeight.bold)),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('한국어 뜻 + 한자 모두 표시'),
                  value: 'both',
                  groupValue: state.quizDisplayField,
                  onChanged: (v) => setDialogState(() => state.quizDisplayField = v!),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('한국어 뜻만 표시'),
                  value: 'meaningOnly',
                  groupValue: state.quizDisplayField,
                  onChanged: (v) => setDialogState(() => state.quizDisplayField = v!),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('한자만 표시 (한자가 없는 단어는 뜻으로 대체)'),
                  value: 'kanjiOnly',
                  groupValue: state.quizDisplayField,
                  onChanged: (v) => setDialogState(() => state.quizDisplayField = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {});
                state.saveUserData();
                Navigator.pop(dialogContext);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer(String val) async {
    if (_isProcessingAnswer || _currentIndex >= _currentQuizData.length) return;
    _isProcessingAnswer = true;

    final state = AppStateManager.instance;
    Word currentWord = _currentQuizData[_currentIndex];

    if (val.trim() == currentWord.jp) {
      if (_isFirstTry && widget.quizType != 'retry') {
        state.unknownWords.removeWhere((w) => w.kr == currentWord.kr && w.jp == currentWord.jp);

        currentWord.correctCount++;
        if (currentWord.correctCount >= 5) {
          state.allWords.removeWhere((w) => w.kr == currentWord.kr && w.jp == currentWord.jp);
          if (!state.completedWords.any((w) => w.kr == currentWord.kr && w.jp == currentWord.jp)) {
            currentWord.correctCount = 0;
            state.completedWords.add(currentWord);
            _masteredThisSession.add(currentWord);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _showCheckmark = true;
        _isFirstTry = true;
        _showError = false;
        _textController.clear();
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _currentIndex++;
          _showCheckmark = false;
        });

        FocusScope.of(context).requestFocus(_focusNode);

        if (_currentIndex < _currentQuizData.length) {
          _fadeController.forward(from: 0.0);
        }
      }
    } else {
      if (_showError) {
        _isProcessingAnswer = false;
        return;
      }

      if (_isFirstTry) {
        if (widget.quizType != 'retry') {
          if (!state.unknownWords.any((w) => w.kr == currentWord.kr && w.jp == currentWord.jp)) {
            state.unknownWords.add(currentWord);
          }
        }
        _currentSessionIncorrect.add(currentWord);
        _isFirstTry = false;
      }

      if (mounted) {
        setState(() {
          _showError = true;
          _textController.clear();
        });
        FocusScope.of(context).requestFocus(_focusNode);
      }
    }

    _isProcessingAnswer = false;
  }

  void _showRequiredPurchaseDialog(PackageInfo requiredPackage) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('잠금 해제 필요', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '무료 제공 단어를 모두 학습하셨습니다.\n다음 단어장(${requiredPackage.displayName})을 계속 학습하려면 결제가 필요합니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple.shade200, Colors.deepPurple.shade300]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text('전체 급수 (N5 ~ N1 총 7,573개 단어)\n영구 무료해제', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('9,900원', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('닫기', style: TextStyle(fontSize: 16, color: Colors.grey))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateManager.instance;

    if (_currentQuizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('시험을 볼 단어가 없습니다.', style: TextStyle(fontSize: 20))),
      );
    }

    if (_currentIndex >= _currentQuizData.length) {
      List<Widget> resultChildren = [
        Text(
          _currentSessionIncorrect.isEmpty ? '완벽합니다! 틀린 단어가 없습니다.' : '수고하셨습니다. ${_currentSessionIncorrect.length}개의 단어를 틀렸습니다.',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _currentSessionIncorrect.isEmpty ? Colors.green : Colors.red),
        ),
        const SizedBox(height: 30),
      ];

      if (_masteredThisSession.isNotEmpty) {
        resultChildren.add(const Text('★누적 정답 5회 달성★', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
        resultChildren.add(const SizedBox(height: 10));
        for (var word in _masteredThisSession) {
          resultChildren.add(
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 18, color: primaryTextColor(context)),
                children: [
                  TextSpan(text: '${word.kr}(${word.jp})', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue)),
                  const TextSpan(text: '가 완료된 단어로 기록되었습니다.'),
                ],
              ),
            ),
          );
          resultChildren.add(const SizedBox(height: 5));
        }
        resultChildren.add(const SizedBox(height: 30));
      }

      if (_currentSessionIncorrect.isNotEmpty) {
        resultChildren.add(
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => QuizScreen(quizType: 'retry', customWords: _currentSessionIncorrect)
              ));
            },
            child: const Text('오답 단어 재시험', style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        );
        resultChildren.add(const SizedBox(height: 15));
      } else {
        resultChildren.add(
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              // [수정된 결과 창에서 새로운 시험보기 클릭 시 결제 체크]
              if (!state.hasAllPackages && state.completedWords.isNotEmpty) {
                final nextPkg = state.nextPackageToUnlock ?? starterPackage;
                _showRequiredPurchaseDialog(nextPkg);
                return;
              }

              await state.refillWordsIfNeeded();
              if (!mounted) return;

              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => const QuizScreen(quizType: 'random')
              ));
            },
            child: const Text('새로운 시험보기', style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        );
        resultChildren.add(const SizedBox(height: 15));
      }

      resultChildren.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          onPressed: () => Navigator.pop(context),
          child: const Text('종료하기', style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      );

      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: resultChildren,
            ),
          ),
        ),
      );
    }

    Word currentWord = _currentQuizData[_currentIndex];

    bool wantKanji = state.quizDisplayField != 'meaningOnly' && currentWord.kanji.isNotEmpty;
    bool wantMeaning = state.quizDisplayField != 'kanjiOnly' || currentWord.kanji.isEmpty;

    Widget kanjiWidget = Text(currentWord.kanji, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600, color: primaryTextColor(context)));
    Widget meaningWidget = Text(currentWord.kr, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue));

    List<Widget> promptWidgets = [];

    if (wantKanji) {
      promptWidgets.add(kanjiWidget);
      promptWidgets.add(const SizedBox(height: 8));
    }
    if (wantMeaning) {
      promptWidgets.add(meaningWidget);
    }

    if (promptWidgets.isEmpty) promptWidgets.add(meaningWidget);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _showQuizModeDialog,
            icon: const Icon(Icons.tune),
            label: const Text('시험모드변경'),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: _showCheckmark
                          ? const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)])
                          : LinearGradient(colors: [Colors.blue.shade300, Colors.indigo.shade400]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _showCheckmark
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            '${_currentIndex + 1} / ${_currentQuizData.length}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    constraints: const BoxConstraints(minWidth: 260),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    decoration: BoxDecoration(
                      color: cardSurfaceColor(context),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: promptWidgets),
                  ),
                  if (_showError) ...[
                    const SizedBox(height: 10),
                    Text('일본어: ${currentWord.jp}', style: const TextStyle(fontSize: 28, color: Colors.red)),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                      onChanged: (val) {
                        if (_currentIndex < _currentQuizData.length) {
                          if (kIsWeb) {
                            if (val.isNotEmpty && val.endsWith(' ')) {
                              _checkAnswer(val.trim());
                            }
                          } else {
                            if (val.trim() == _currentQuizData[_currentIndex].jp) {
                              _checkAnswer(val.trim());
                            }
                          }
                        }
                      },
                      onSubmitted: (val) {
                        if (_currentIndex < _currentQuizData.length) {
                          _checkAnswer(val.trim());
                        }
                      },
                      decoration: InputDecoration(
                        hintText: _showError ? currentWord.jp : '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _showError ? Colors.red : Colors.grey, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: _showError ? Colors.red : Colors.grey, width: 2),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PackageLevelScreen extends StatefulWidget {
  final String level;
  const PackageLevelScreen({super.key, required this.level});
  @override
  State<PackageLevelScreen> createState() => _PackageLevelScreenState();
}

class _PackageLevelScreenState extends State<PackageLevelScreen> {
  @override
  Widget build(BuildContext context) {
    final List<PackageInfo> packages = packagesForLevel(widget.level);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.level} 단어장'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: screenBackgroundGradient(context))),
          ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: packages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final PackageInfo pkg = packages[index];
              final String? status = packageStatusLabel(pkg);
              final bool inProgress = status == '진행중';

              Color cardBgColor = cardSurfaceColor(context);
              if (inProgress) {
                cardBgColor = AppStateManager.instance.isDarkMode ? const Color(0xFF2C3E75) : const Color(0xFFFFF8E7);
              }

              return Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: inProgress ? Colors.amber : Colors.transparent,
                    width: inProgress ? 1.5 : 0,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PackageDetailScreen(package: pkg)),
                      );
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          _LevelBadge(level: pkg.level, text: '${pkg.indexInLevel}', size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pkg.isStarter ? '단어장 ${pkg.indexInLevel} (기본 제공)' : '단어장 ${pkg.indexInLevel}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: primaryTextColor(context),
                                    fontWeight: inProgress ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  '${pkg.count}단어',
                                  style: TextStyle(fontSize: 12, color: secondaryTextColor(context)),
                                ),
                              ],
                            ),
                          ),
                          statusBadge(status),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: secondaryTextColor(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PackageDetailScreen extends StatefulWidget {
  final PackageInfo package;
  const PackageDetailScreen({super.key, required this.package});
  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  List<Word>? _words;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = AppStateManager.instance;
    try {
      if (state.packageCache.containsKey(widget.package.docId)) {
        setState(() { _words = state.packageCache[widget.package.docId]; });
        return;
      }
      final doc = await FirebaseFirestore.instance.collection('words').doc(widget.package.docId).get();
      if (doc.exists) {
        final wordsData = (doc.data()?['wordsList'] as List?) ?? [];
        final words = wordsData.map((w) => Word.fromPackageEntry(w, widget.package.docId)).toList();
        state.packageCache[widget.package.docId] = words.map((w) => w.copy()).toList();
        if (mounted) setState(() { _words = words; });
      } else {
        if (mounted) setState(() { _error = '단어장을 찾을 수 없습니다.'; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '단어를 불러오는 중 오류가 발생했습니다.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.package.displayName} 단어 목록'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: screenBackgroundGradient(context))),
          _error != null
              ? Center(child: Text(_error!))
              : _words == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      itemCount: _words!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final Word w = _words![index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardSurfaceColor(context),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (w.kanji.isNotEmpty)
                                Text(w.kanji, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: primaryTextColor(context))),
                              Text(w.hiragana, style: TextStyle(fontSize: 16, color: secondaryTextColor(context))),
                              const SizedBox(height: 4),
                              Text('뜻: ${w.kr}', style: TextStyle(fontSize: 15, color: primaryTextColor(context))),
                              Text('발음: ${w.jp}', style: const TextStyle(fontSize: 14, color: Colors.teal)),
                            ],
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}