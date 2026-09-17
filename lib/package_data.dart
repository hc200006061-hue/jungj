// JLPT 난이도별 단어 패키지 순서를 정의합니다. (쉬운 순: N5 -> N4 -> N3 -> N2 -> N1)

class PackageInfo {
  final String docId;
  final String level;
  final int indexInLevel;
  final int count;
  final int order;
  final bool isStarter; // 각 난이도의 1번 단어장 여부

  const PackageInfo({
    required this.docId,
    required this.level,
    required this.indexInLevel,
    required this.count,
    required this.order,
    this.isStarter = false,
  });

  String get displayName => '$level-$indexInLevel';
}

// 각 난이도의 1번 단어장들은 기본 제공 (무료 해제)
const List<PackageInfo> starterPackages = [
  PackageInfo(docId: '기본', level: 'N5', indexInLevel: 1, count: 50, order: 0, isStarter: true),
  PackageInfo(docId: 'N4-1', level: 'N4', indexInLevel: 1, count: 50, order: 12, isStarter: true),
  PackageInfo(docId: 'N3-1', level: 'N3', indexInLevel: 1, count: 50, order: 30, isStarter: true),
  PackageInfo(docId: 'N2-1', level: 'N2', indexInLevel: 1, count: 50, order: 55, isStarter: true),
  PackageInfo(docId: 'N1-1', level: 'N1', indexInLevel: 1, count: 50, order: 100, isStarter: true),
];

const PackageInfo starterPackage = PackageInfo(docId: '기본', level: 'N5', indexInLevel: 1, count: 50, order: 0, isStarter: true);

// 구매/해제 대상 및 전체 패키지 목록
const List<PackageInfo> packageOrder = [
  PackageInfo(docId: 'N5-2', level: 'N5', indexInLevel: 2, count: 50, order: 1),
  PackageInfo(docId: 'N5-3', level: 'N5', indexInLevel: 3, count: 50, order: 2),
  PackageInfo(docId: 'N5-4', level: 'N5', indexInLevel: 4, count: 50, order: 3),
  PackageInfo(docId: 'N5-5', level: 'N5', indexInLevel: 5, count: 50, order: 4),
  PackageInfo(docId: 'N5-6', level: 'N5', indexInLevel: 6, count: 50, order: 5),
  PackageInfo(docId: 'N5-7', level: 'N5', indexInLevel: 7, count: 50, order: 6),
  PackageInfo(docId: 'N5-8', level: 'N5', indexInLevel: 8, count: 50, order: 7),
  PackageInfo(docId: 'N5-9', level: 'N5', indexInLevel: 9, count: 50, order: 8),
  PackageInfo(docId: 'N5-10', level: 'N5', indexInLevel: 10, count: 50, order: 9),
  PackageInfo(docId: 'N5-11', level: 'N5', indexInLevel: 11, count: 50, order: 10),
  PackageInfo(docId: 'N5-12', level: 'N5', indexInLevel: 12, count: 30, order: 11),
  PackageInfo(docId: 'N4-1', level: 'N4', indexInLevel: 1, count: 50, order: 12, isStarter: true),
  PackageInfo(docId: 'N4-2', level: 'N4', indexInLevel: 2, count: 50, order: 13),
  PackageInfo(docId: 'N4-3', level: 'N4', indexInLevel: 3, count: 50, order: 14),
  PackageInfo(docId: 'N4-4', level: 'N4', indexInLevel: 4, count: 50, order: 15),
  PackageInfo(docId: 'N4-5', level: 'N4', indexInLevel: 5, count: 50, order: 16),
  PackageInfo(docId: 'N4-6', level: 'N4', indexInLevel: 6, count: 50, order: 17),
  PackageInfo(docId: 'N4-7', level: 'N4', indexInLevel: 7, count: 50, order: 18),
  PackageInfo(docId: 'N4-8', level: 'N4', indexInLevel: 8, count: 50, order: 19),
  PackageInfo(docId: 'N4-9', level: 'N4', indexInLevel: 9, count: 50, order: 20),
  PackageInfo(docId: 'N4-10', level: 'N4', indexInLevel: 10, count: 50, order: 21),
  PackageInfo(docId: 'N4-11', level: 'N4', indexInLevel: 11, count: 50, order: 22),
  PackageInfo(docId: 'N4-12', level: 'N4', indexInLevel: 12, count: 50, order: 23),
  PackageInfo(docId: 'N4-13', level: 'N4', indexInLevel: 13, count: 50, order: 24),
  PackageInfo(docId: 'N4-14', level: 'N4', indexInLevel: 14, count: 50, order: 25),
  PackageInfo(docId: 'N4-15', level: 'N4', indexInLevel: 15, count: 50, order: 26),
  PackageInfo(docId: 'N4-16', level: 'N4', indexInLevel: 16, count: 50, order: 27),
  PackageInfo(docId: 'N4-17', level: 'N4', indexInLevel: 17, count: 50, order: 28),
  PackageInfo(docId: 'N4-18', level: 'N4', indexInLevel: 18, count: 20, order: 29),
  PackageInfo(docId: 'N3-1', level: 'N3', indexInLevel: 1, count: 50, order: 30, isStarter: true),
  PackageInfo(docId: 'N3-2', level: 'N3', indexInLevel: 2, count: 50, order: 31),
  PackageInfo(docId: 'N3-3', level: 'N3', indexInLevel: 3, count: 50, order: 32),
  PackageInfo(docId: 'N3-4', level: 'N3', indexInLevel: 4, count: 50, order: 33),
  PackageInfo(docId: 'N3-5', level: 'N3', indexInLevel: 5, count: 50, order: 34),
  PackageInfo(docId: 'N3-6', level: 'N3', indexInLevel: 6, count: 50, order: 35),
  PackageInfo(docId: 'N3-7', level: 'N3', indexInLevel: 7, count: 50, order: 36),
  PackageInfo(docId: 'N3-8', level: 'N3', indexInLevel: 8, count: 50, order: 37),
  PackageInfo(docId: 'N3-9', level: 'N3', indexInLevel: 9, count: 50, order: 38),
  PackageInfo(docId: 'N3-10', level: 'N3', indexInLevel: 10, count: 50, order: 39),
  PackageInfo(docId: 'N3-11', level: 'N3', indexInLevel: 11, count: 50, order: 40),
  PackageInfo(docId: 'N3-12', level: 'N3', indexInLevel: 12, count: 50, order: 41),
  PackageInfo(docId: 'N3-13', level: 'N3', indexInLevel: 13, count: 50, order: 42),
  PackageInfo(docId: 'N3-14', level: 'N3', indexInLevel: 14, count: 50, order: 43),
  PackageInfo(docId: 'N3-15', level: 'N3', indexInLevel: 15, count: 50, order: 44),
  PackageInfo(docId: 'N3-16', level: 'N3', indexInLevel: 16, count: 50, order: 45),
  PackageInfo(docId: 'N3-17', level: 'N3', indexInLevel: 17, count: 50, order: 46),
  PackageInfo(docId: 'N3-18', level: 'N3', indexInLevel: 18, count: 50, order: 47),
  PackageInfo(docId: 'N3-19', level: 'N3', indexInLevel: 19, count: 50, order: 48),
  PackageInfo(docId: 'N3-20', level: 'N3', indexInLevel: 20, count: 50, order: 49),
  PackageInfo(docId: 'N3-21', level: 'N3', indexInLevel: 21, count: 50, order: 50),
  PackageInfo(docId: 'N3-22', level: 'N3', indexInLevel: 22, count: 50, order: 51),
  PackageInfo(docId: 'N3-23', level: 'N3', indexInLevel: 23, count: 50, order: 52),
  PackageInfo(docId: 'N3-24', level: 'N3', indexInLevel: 24, count: 50, order: 53),
  PackageInfo(docId: 'N3-25', level: 'N3', indexInLevel: 25, count: 17, order: 54),
  PackageInfo(docId: 'N2-1', level: 'N2', indexInLevel: 1, count: 50, order: 55, isStarter: true),
  PackageInfo(docId: 'N2-2', level: 'N2', indexInLevel: 2, count: 50, order: 56),
  PackageInfo(docId: 'N2-3', level: 'N2', indexInLevel: 3, count: 50, order: 57),
  PackageInfo(docId: 'N2-4', level: 'N2', indexInLevel: 4, count: 50, order: 58),
  PackageInfo(docId: 'N2-5', level: 'N2', indexInLevel: 5, count: 50, order: 59),
  PackageInfo(docId: 'N2-6', level: 'N2', indexInLevel: 6, count: 50, order: 60),
  PackageInfo(docId: 'N2-7', level: 'N2', indexInLevel: 7, count: 50, order: 61),
  PackageInfo(docId: 'N2-8', level: 'N2', indexInLevel: 8, count: 50, order: 62),
  PackageInfo(docId: 'N2-9', level: 'N2', indexInLevel: 9, count: 50, order: 63),
  PackageInfo(docId: 'N2-10', level: 'N2', indexInLevel: 10, count: 50, order: 64),
  PackageInfo(docId: 'N2-11', level: 'N2', indexInLevel: 11, count: 50, order: 65),
  PackageInfo(docId: 'N2-12', level: 'N2', indexInLevel: 12, count: 50, order: 66),
  PackageInfo(docId: 'N2-13', level: 'N2', indexInLevel: 13, count: 50, order: 67),
  PackageInfo(docId: 'N2-14', level: 'N2', indexInLevel: 14, count: 50, order: 68),
  PackageInfo(docId: 'N2-15', level: 'N2', indexInLevel: 15, count: 50, order: 69),
  PackageInfo(docId: 'N2-16', level: 'N2', indexInLevel: 16, count: 50, order: 70),
  PackageInfo(docId: 'N2-17', level: 'N2', indexInLevel: 17, count: 50, order: 71),
  PackageInfo(docId: 'N2-18', level: 'N2', indexInLevel: 18, count: 50, order: 72),
  PackageInfo(docId: 'N2-19', level: 'N2', indexInLevel: 19, count: 50, order: 73),
  PackageInfo(docId: 'N2-20', level: 'N2', indexInLevel: 20, count: 50, order: 74),
  PackageInfo(docId: 'N2-21', level: 'N2', indexInLevel: 21, count: 50, order: 75),
  PackageInfo(docId: 'N2-22', level: 'N2', indexInLevel: 22, count: 50, order: 76),
  PackageInfo(docId: 'N2-23', level: 'N2', indexInLevel: 23, count: 50, order: 77),
  PackageInfo(docId: 'N2-24', level: 'N2', indexInLevel: 24, count: 50, order: 78),
  PackageInfo(docId: 'N2-25', level: 'N2', indexInLevel: 25, count: 50, order: 79),
  PackageInfo(docId: 'N2-26', level: 'N2', indexInLevel: 26, count: 50, order: 80),
  PackageInfo(docId: 'N2-27', level: 'N2', indexInLevel: 27, count: 50, order: 81),
  PackageInfo(docId: 'N2-28', level: 'N2', indexInLevel: 28, count: 50, order: 82),
  PackageInfo(docId: 'N2-29', level: 'N2', indexInLevel: 29, count: 50, order: 83),
  PackageInfo(docId: 'N2-30', level: 'N2', indexInLevel: 30, count: 50, order: 84),
  PackageInfo(docId: 'N2-31', level: 'N2', indexInLevel: 31, count: 50, order: 85),
  PackageInfo(docId: 'N2-32', level: 'N2', indexInLevel: 32, count: 50, order: 86),
  PackageInfo(docId: 'N2-33', level: 'N2', indexInLevel: 33, count: 50, order: 87),
  PackageInfo(docId: 'N2-34', level: 'N2', indexInLevel: 34, count: 50, order: 88),
  PackageInfo(docId: 'N2-35', level: 'N2', indexInLevel: 35, count: 50, order: 89),
  PackageInfo(docId: 'N2-36', level: 'N2', indexInLevel: 36, count: 50, order: 90),
  PackageInfo(docId: 'N2-37', level: 'N2', indexInLevel: 37, count: 50, order: 91),
  PackageInfo(docId: 'N2-38', level: 'N2', indexInLevel: 38, count: 50, order: 92),
  PackageInfo(docId: 'N2-39', level: 'N2', indexInLevel: 39, count: 50, order: 93),
  PackageInfo(docId: 'N2-40', level: 'N2', indexInLevel: 40, count: 50, order: 94),
  PackageInfo(docId: 'N2-41', level: 'N2', indexInLevel: 41, count: 50, order: 95),
  PackageInfo(docId: 'N2-42', level: 'N2', indexInLevel: 42, count: 50, order: 96),
  PackageInfo(docId: 'N2-43', level: 'N2', indexInLevel: 43, count: 50, order: 97),
  PackageInfo(docId: 'N2-44', level: 'N2', indexInLevel: 44, count: 50, order: 98),
  PackageInfo(docId: 'N2-45', level: 'N2', indexInLevel: 45, count: 44, order: 99),
  PackageInfo(docId: 'N1-1', level: 'N1', indexInLevel: 1, count: 50, order: 100, isStarter: true),
  PackageInfo(docId: 'N1-2', level: 'N1', indexInLevel: 2, count: 50, order: 101),
  PackageInfo(docId: 'N1-3', level: 'N1', indexInLevel: 3, count: 50, order: 102),
  PackageInfo(docId: 'N1-4', level: 'N1', indexInLevel: 4, count: 50, order: 103),
  PackageInfo(docId: 'N1-5', level: 'N1', indexInLevel: 5, count: 50, order: 104),
  PackageInfo(docId: 'N1-6', level: 'N1', indexInLevel: 6, count: 50, order: 105),
  PackageInfo(docId: 'N1-7', level: 'N1', indexInLevel: 7, count: 50, order: 106),
  PackageInfo(docId: 'N1-8', level: 'N1', indexInLevel: 8, count: 50, order: 107),
  PackageInfo(docId: 'N1-9', level: 'N1', indexInLevel: 9, count: 50, order: 108),
  PackageInfo(docId: 'N1-10', level: 'N1', indexInLevel: 10, count: 50, order: 109),
  PackageInfo(docId: 'N1-11', level: 'N1', indexInLevel: 11, count: 50, order: 110),
  PackageInfo(docId: 'N1-12', level: 'N1', indexInLevel: 12, count: 50, order: 111),
  PackageInfo(docId: 'N1-13', level: 'N1', indexInLevel: 13, count: 50, order: 112),
  PackageInfo(docId: 'N1-14', level: 'N1', indexInLevel: 14, count: 50, order: 113),
  PackageInfo(docId: 'N1-15', level: 'N1', indexInLevel: 15, count: 50, order: 114),
  PackageInfo(docId: 'N1-16', level: 'N1', indexInLevel: 16, count: 50, order: 115),
  PackageInfo(docId: 'N1-17', level: 'N1', indexInLevel: 17, count: 50, order: 116),
  PackageInfo(docId: 'N1-18', level: 'N1', indexInLevel: 18, count: 50, order: 117),
  PackageInfo(docId: 'N1-19', level: 'N1', indexInLevel: 19, count: 50, order: 118),
  PackageInfo(docId: 'N1-20', level: 'N1', indexInLevel: 20, count: 50, order: 119),
  PackageInfo(docId: 'N1-21', level: 'N1', indexInLevel: 21, count: 50, order: 120),
  PackageInfo(docId: 'N1-22', level: 'N1', indexInLevel: 22, count: 50, order: 121),
  PackageInfo(docId: 'N1-23', level: 'N1', indexInLevel: 23, count: 50, order: 122),
  PackageInfo(docId: 'N1-24', level: 'N1', indexInLevel: 24, count: 50, order: 123),
  PackageInfo(docId: 'N1-25', level: 'N1', indexInLevel: 25, count: 50, order: 124),
  PackageInfo(docId: 'N1-26', level: 'N1', indexInLevel: 26, count: 50, order: 125),
  PackageInfo(docId: 'N1-27', level: 'N1', indexInLevel: 27, count: 50, order: 126),
  PackageInfo(docId: 'N1-28', level: 'N1', indexInLevel: 28, count: 50, order: 127),
  PackageInfo(docId: 'N1-29', level: 'N1', indexInLevel: 29, count: 50, order: 128),
  PackageInfo(docId: 'N1-30', level: 'N1', indexInLevel: 30, count: 50, order: 129),
  PackageInfo(docId: 'N1-31', level: 'N1', indexInLevel: 31, count: 50, order: 130),
  PackageInfo(docId: 'N1-32', level: 'N1', indexInLevel: 32, count: 50, order: 131),
  PackageInfo(docId: 'N1-33', level: 'N1', indexInLevel: 33, count: 50, order: 132),
  PackageInfo(docId: 'N1-34', level: 'N1', indexInLevel: 34, count: 50, order: 133),
  PackageInfo(docId: 'N1-35', level: 'N1', indexInLevel: 35, count: 50, order: 134),
  PackageInfo(docId: 'N1-36', level: 'N1', indexInLevel: 36, count: 50, order: 135),
  PackageInfo(docId: 'N1-37', level: 'N1', indexInLevel: 37, count: 50, order: 136),
  PackageInfo(docId: 'N1-38', level: 'N1', indexInLevel: 38, count: 50, order: 137),
  PackageInfo(docId: 'N1-39', level: 'N1', indexInLevel: 39, count: 50, order: 138),
  PackageInfo(docId: 'N1-40', level: 'N1', indexInLevel: 40, count: 50, order: 139),
  PackageInfo(docId: 'N1-41', level: 'N1', indexInLevel: 41, count: 50, order: 140),
  PackageInfo(docId: 'N1-42', level: 'N1', indexInLevel: 42, count: 50, order: 141),
  PackageInfo(docId: 'N1-43', level: 'N1', indexInLevel: 43, count: 50, order: 142),
  PackageInfo(docId: 'N1-44', level: 'N1', indexInLevel: 44, count: 50, order: 143),
  PackageInfo(docId: 'N1-45', level: 'N1', indexInLevel: 45, count: 50, order: 144),
  PackageInfo(docId: 'N1-46', level: 'N1', indexInLevel: 46, count: 50, order: 145),
  PackageInfo(docId: 'N1-47', level: 'N1', indexInLevel: 47, count: 50, order: 146),
  PackageInfo(docId: 'N1-48', level: 'N1', indexInLevel: 48, count: 50, order: 147),
  PackageInfo(docId: 'N1-49', level: 'N1', indexInLevel: 49, count: 50, order: 148),
  PackageInfo(docId: 'N1-50', level: 'N1', indexInLevel: 50, count: 50, order: 149),
  PackageInfo(docId: 'N1-51', level: 'N1', indexInLevel: 51, count: 50, order: 150),
  PackageInfo(docId: 'N1-52', level: 'N1', indexInLevel: 52, count: 50, order: 151),
  PackageInfo(docId: 'N1-53', level: 'N1', indexInLevel: 53, count: 50, order: 152),
  PackageInfo(docId: 'N1-54', level: 'N1', indexInLevel: 54, count: 12, order: 153),
];

const List<String> levelOrder = ['N5', 'N4', 'N3', 'N2', 'N1'];

int get totalPurchasableWordCount => packageOrder.fold(0, (sum, p) => sum + p.count);

PackageInfo? packageForOrder(int order) {
  for (final p in packageOrder) {
    if (p.order == order) return p;
  }
  return null;
}

List<PackageInfo> packagesForLevel(String level) {
  final list = packageOrder.where((p) => p.level == level).toList();
  if (level == 'N5') {
    return [starterPackage, ...list.where((p) => p.docId != '기본')];
  }
  return list;
}

int totalWordCountForLevel(String level) =>
    packagesForLevel(level).fold(0, (sum, p) => sum + p.count);