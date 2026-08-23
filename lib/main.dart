import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'firebase_options.dart';

class Word {
  String kr;
  String jp;
  int correctCount;

  Word({required this.kr, required this.jp, this.correctCount = 0});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      kr: json['kr'],
      jp: json['jp'].toString().replaceAll('-', ''),
      correctCount: json['correctCount'] ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {'kr': kr, 'jp': jp, 'correctCount': correctCount};
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Word && kr == other.kr && jp == other.jp;

  @override
  int get hashCode => kr.hashCode ^ jp.hashCode;
}

// 1. 기본 100단어 (하이픈 완벽 제거 완료)
final List<Word> defaultWords = [
  Word(kr: '나', jp: '와타시'), Word(kr: '너', jp: '아나타'), Word(kr: '우리', jp: '와타시타치'), Word(kr: '이것', jp: '코레'), Word(kr: '그것', jp: '소레'), Word(kr: '저것', jp: '아레'), Word(kr: '여기', jp: '코코'), Word(kr: '거기', jp: '소코'), Word(kr: '저기', jp: '아소코'), Word(kr: '누구', jp: '다레'), Word(kr: '무엇', jp: '나니'), Word(kr: '어디', jp: '도코'), Word(kr: '언제', jp: '이츠'), Word(kr: '왜', jp: '나제'), Word(kr: '어떻게', jp: '도야테'), Word(kr: '안녕하세요', jp: '콘니치와'), Word(kr: '안녕히계세요', jp: '사요나라'), Word(kr: '감사합니다', jp: '아리가토'), Word(kr: '죄송합니다', jp: '스미마센'), Word(kr: '네', jp: '하이'), Word(kr: '아니요', jp: '이이에'), Word(kr: '괜찮습니다', jp: '다이조부데스'), Word(kr: '수고하셨습니다', jp: '오츠카레사마데시타'), Word(kr: '오늘', jp: '쿄'), Word(kr: '내일', jp: '아시타'), Word(kr: '어제', jp: '키노'), Word(kr: '지금', jp: '이마'), Word(kr: '아침', jp: '아사'), Word(kr: '점심', jp: '히루'), Word(kr: '저녁', jp: '요루'), Word(kr: '매일', jp: '마이니치'), Word(kr: '시간', jp: '지칸'), Word(kr: '시', jp: '지'), Word(kr: '분', jp: '분'), Word(kr: '사람', jp: '히토'), Word(kr: '남자', jp: '오토코'), Word(kr: '여자', jp: '온나'), Word(kr: '친구', jp: '토모다치'), Word(kr: '가족', jp: '카조쿠'), Word(kr: '이름', jp: '나마에'), Word(kr: '나라', jp: '쿠니'), Word(kr: '집', jp: '이에'), Word(kr: '방', jp: '헤야'), Word(kr: '문', jp: '도어'), Word(kr: '창문', jp: '마도'), Word(kr: '책', jp: '혼'), Word(kr: '책상', jp: '츠쿠에'), Word(kr: '의자', jp: '이스'), Word(kr: '물', jp: '미즈'), Word(kr: '밥', jp: '고한'), Word(kr: '차', jp: '오차'), Word(kr: '돈', jp: '오카네'), Word(kr: '일', jp: '시고토'), Word(kr: '학교', jp: '갓코'), Word(kr: '회사', jp: '카이샤'), Word(kr: '병원', jp: '뵤인'), Word(kr: '화장실', jp: '토이레'), Word(kr: '가게', jp: '미세'), Word(kr: '길', jp: '미치'), Word(kr: '역', jp: '에키'), Word(kr: '자동차', jp: '쿠루마'), Word(kr: '전철', jp: '덴샤'), Word(kr: '비행기', jp: '히코키'), Word(kr: '문제', jp: '몬다이'), Word(kr: '마음', jp: '코코로'), Word(kr: '몸', jp: '카라다'), Word(kr: '손', jp: '테'), Word(kr: '발', jp: '아시'), Word(kr: '눈', jp: '메'), Word(kr: '입', jp: '쿠치'), Word(kr: '귀', jp: '미미'), Word(kr: '가다', jp: '이쿠'), Word(kr: '오다', jp: '쿠루'), Word(kr: '먹다', jp: '타베루'), Word(kr: '마시다', jp: '노무'), Word(kr: '자다', jp: '네루'), Word(kr: '일어나다', jp: '오키루'), Word(kr: '보다', jp: '미루'), Word(kr: '듣다', jp: '키쿠'), Word(kr: '말하다', jp: '하나스'), Word(kr: '읽다', jp: '요무'), Word(kr: '쓰다', jp: '카쿠'), Word(kr: '사다', jp: '카우'), Word(kr: '하다', jp: '스루'), Word(kr: '모르다', jp: '시라나이'), Word(kr: '좋아하다', jp: '스키다'), Word(kr: '싫어하다', jp: '키라이다'), Word(kr: '크다', jp: '오오키이'), Word(kr: '작다', jp: '치이사이'), Word(kr: '많다', jp: '오오이'), Word(kr: '적다', jp: '스크나이'), Word(kr: '좋다', jp: '이이'), Word(kr: '나쁘다', jp: '와루이'), Word(kr: '새롭다', jp: '아타라시이'), Word(kr: '낡다', jp: '후루이'), Word(kr: '덥다', jp: '아츠이'), Word(kr: '춥다', jp: '사무이'), Word(kr: '어렵다', jp: '무즈카시이'), Word(kr: '쉽다', jp: '야사시이'), Word(kr: '지하철', jp: '치카테츠')
];

// 2. 1살~10살 패키지 500단어 (하이픈 완벽 제거 완료)
final Map<int, List<Word>> packageWords = {
  1: [Word(kr: '고기', jp: '니쿠'), Word(kr: '생선', jp: '사카나'), Word(kr: '야채', jp: '야사이'), Word(kr: '과일', jp: '쿠다모노'), Word(kr: '빵', jp: '판'), Word(kr: '우유', jp: '규뉴'), Word(kr: '커피', jp: '코히'), Word(kr: '술', jp: '오사케'), Word(kr: '아침식사', jp: '초쇼쿠'), Word(kr: '점심식사', jp: '츄쇼쿠'), Word(kr: '저녁식사', jp: '유쇼쿠'), Word(kr: '소금', jp: '시오'), Word(kr: '설탕', jp: '사토'), Word(kr: '간장', jp: '쇼유'), Word(kr: '계란', jp: '타마고'), Word(kr: '사과', jp: '링고'), Word(kr: '귤', jp: '미칸'), Word(kr: '딸기', jp: '이치고'), Word(kr: '포도', jp: '부도'), Word(kr: '바나나', jp: '바나나'), Word(kr: '수박', jp: '스이카'), Word(kr: '시계', jp: '토케이'), Word(kr: '안경', jp: '메가네'), Word(kr: '우산', jp: '카사'), Word(kr: '가방', jp: '카반'), Word(kr: '지갑', jp: '사이후'), Word(kr: '구두', jp: '쿠츠'), Word(kr: '옷', jp: '후쿠'), Word(kr: '바지', jp: '즈본'), Word(kr: '치마', jp: '스카토'), Word(kr: '모자', jp: '보시'), Word(kr: '셔츠', jp: '샤츠'), Word(kr: '양말', jp: '쿠츠시타'), Word(kr: '속옷', jp: '시타기'), Word(kr: '넥타이', jp: '네쿠타이'), Word(kr: '손수건', jp: '한카치'), Word(kr: '장갑', jp: '테부쿠로'), Word(kr: '거울', jp: '카가미'), Word(kr: '가위', jp: '하사미'), Word(kr: '연필', jp: '엔피츠'), Word(kr: '볼펜', jp: '보루펜'), Word(kr: '지우개', jp: '케시고무'), Word(kr: '공책', jp: '노토'), Word(kr: '사전', jp: '지쇼'), Word(kr: '신문', jp: '신분'), Word(kr: '잡지', jp: '자시'), Word(kr: '사진', jp: '샤신'), Word(kr: '그림', jp: '에'), Word(kr: '음악', jp: '온가쿠'), Word(kr: '영화', jp: '에이가')],
  2: [Word(kr: '취미', jp: '슈미'), Word(kr: '운동', jp: '운도'), Word(kr: '여행', jp: '료코'), Word(kr: '사진기', jp: '카메라'), Word(kr: '전화', jp: '덴와'), Word(kr: '핸드폰', jp: '케이타이'), Word(kr: '컴퓨터', jp: '파소콘'), Word(kr: '텔레비전', jp: '테레비'), Word(kr: '라디오', jp: '라지오'), Word(kr: '냉장고', jp: '레이조코'), Word(kr: '세탁기', jp: '센타쿠키'), Word(kr: '청소기', jp: '소지키'), Word(kr: '침대', jp: '벳도'), Word(kr: '이불', jp: '후톤'), Word(kr: '베개', jp: '마쿠라'), Word(kr: '수건', jp: '타오루'), Word(kr: '비누', jp: '셋켄'), Word(kr: '칫솔', jp: '하부라시'), Word(kr: '치약', jp: '하미가키코'), Word(kr: '샴푸', jp: '샨푸'), Word(kr: '린스', jp: '린스'), Word(kr: '화장지', jp: '토이레토페파'), Word(kr: '쓰레기', jp: '고미'), Word(kr: '휴지통', jp: '고미바코'), Word(kr: '우체국', jp: '유빈쿄쿠'), Word(kr: '은행', jp: '긴코'), Word(kr: '경찰서', jp: '케이사츠쇼'), Word(kr: '도서관', jp: '토쇼칸'), Word(kr: '미술관', jp: '비쥬츠칸'), Word(kr: '박물관', jp: '하쿠부츠칸'), Word(kr: '영화관', jp: '에이가칸'), Word(kr: '공원', jp: '코엔'), Word(kr: '동물원', jp: '도부츠엔'), Word(kr: '식물원', jp: '쇼쿠부츠엔'), Word(kr: '놀이공원', jp: '유엔치'), Word(kr: '바다', jp: '우미'), Word(kr: '산', jp: '야마'), Word(kr: '강', jp: '카와'), Word(kr: '호수', jp: '미즈우미'), Word(kr: '섬', jp: '시마'), Word(kr: '하늘', jp: '소라'), Word(kr: '별', jp: '호시'), Word(kr: '달', jp: '츠키'), Word(kr: '해', jp: '타이요'), Word(kr: '구름', jp: '쿠모'), Word(kr: '비', jp: '아메'), Word(kr: '눈(날씨)', jp: '유키'), Word(kr: '바람', jp: '카제'), Word(kr: '천둥', jp: '카미나리'), Word(kr: '번개', jp: '이나즈마')],
  3: [Word(kr: '봄', jp: '하루'), Word(kr: '여름', jp: '나츠'), Word(kr: '가을', jp: '아키'), Word(kr: '겨울', jp: '후유'), Word(kr: '계절', jp: '키세츠'), Word(kr: '날씨', jp: '텐키'), Word(kr: '맑음', jp: '하레'), Word(kr: '흐림', jp: '쿠모리'), Word(kr: '따뜻하다', jp: '아타타카이'), Word(kr: '시원하다', jp: '스즈시이'), Word(kr: '뜨겁다', jp: '아츠이(물건)'), Word(kr: '차갑다', jp: '츠메타이'), Word(kr: '무겁다', jp: '오모이'), Word(kr: '가볍다', jp: '카루이'), Word(kr: '길다', jp: '나가이'), Word(kr: '짧다', jp: '미지카이'), Word(kr: '넓다', jp: '히로이'), Word(kr: '좁다', jp: '세마이'), Word(kr: '높다', jp: '타카이'), Word(kr: '낮다', jp: '히쿠이'), Word(kr: '비싸다', jp: '타카이(가격)'), Word(kr: '싸다', jp: '야스이'), Word(kr: '빠르다', jp: '하야이'), Word(kr: '느리다', jp: '오소이'), Word(kr: '강하다', jp: '츠요이'), Word(kr: '약하다', jp: '요와이'), Word(kr: '밝다', jp: '아카루이'), Word(kr: '어둡다', jp: '쿠라이'), Word(kr: '멀다', jp: '토오이'), Word(kr: '가깝다', jp: '치카이'), Word(kr: '맛있다', jp: '오이시이'), Word(kr: '맛없다', jp: '마즈이'), Word(kr: '달다', jp: '아마이'), Word(kr: '맵다', jp: '카라이'), Word(kr: '짜다', jp: '쇼파이'), Word(kr: '시다', jp: '스파이'), Word(kr: '쓰다(맛)', jp: '니가이'), Word(kr: '즐겁다', jp: '타노시이'), Word(kr: '기쁘다', jp: '우레시이'), Word(kr: '슬프다', jp: '카나시이'), Word(kr: '외롭다', jp: '사비시이'), Word(kr: '무섭다', jp: '코와이'), Word(kr: '아프다', jp: '이타이'), Word(kr: '바쁘다', jp: '이소가시이'), Word(kr: '한가하다', jp: '히마다'), Word(kr: '편리하다', jp: '벤리다'), Word(kr: '불편하다', jp: '후벤다'), Word(kr: '친절하다', jp: '신세츠다'), Word(kr: '유명하다', jp: '유메이다'), Word(kr: '조용하다', jp: '시즈카다')],
  4: [Word(kr: '시끄럽다', jp: '우루사이'), Word(kr: '깨끗하다', jp: '키레이다'), Word(kr: '더럽다', jp: '키타나이'), Word(kr: '예쁘다', jp: '키레이다(외모)'), Word(kr: '멋지다', jp: '카코이이'), Word(kr: '귀엽다', jp: '카와이이'), Word(kr: '빨강', jp: '아카'), Word(kr: '파랑', jp: '아오'), Word(kr: '노랑', jp: '키이로'), Word(kr: '초록', jp: '미도리'), Word(kr: '검정', jp: '쿠로'), Word(kr: '하양', jp: '시로'), Word(kr: '월요일', jp: '게츠요비'), Word(kr: '화요일', jp: '카요비'), Word(kr: '수요일', jp: '스이요비'), Word(kr: '목요일', jp: '모쿠요비'), Word(kr: '금요일', jp: '킨요비'), Word(kr: '토요일', jp: '도요비'), Word(kr: '일요일', jp: '니치요비'), Word(kr: '주말', jp: '슈마츠'), Word(kr: '이번 주', jp: '콘슈'), Word(kr: '다음 주', jp: '라이슈'), Word(kr: '지난 주', jp: '센슈'), Word(kr: '올해', jp: '코토시'), Word(kr: '내년', jp: '라이넨'), Word(kr: '작년', jp: '쿄넨'), Word(kr: '봄방학', jp: '하루야스미'), Word(kr: '여름방학', jp: '나츠야스미'), Word(kr: '겨울방학', jp: '후유야스미'), Word(kr: '생일', jp: '탄조비'), Word(kr: '파티', jp: '파티'), Word(kr: '선물', jp: '프레젠토'), Word(kr: '꽃', jp: '하나'), Word(kr: '나무', jp: '키'), Word(kr: '풀', jp: '쿠사'), Word(kr: '개', jp: '이누'), Word(kr: '고양이', jp: '네코'), Word(kr: '새', jp: '토리'), Word(kr: '물고기', jp: '사카나(동물)'), Word(kr: '벌레', jp: '무시'), Word(kr: '우유', jp: '미루쿠'), Word(kr: '주스', jp: '쥬스'), Word(kr: '차(마시는 것)', jp: '오차'), Word(kr: '홍차', jp: '코차'), Word(kr: '물', jp: '오히야'), Word(kr: '얼음', jp: '코리'), Word(kr: '뜨거운 물', jp: '오유'), Word(kr: '메뉴', jp: '메뉴'), Word(kr: '주문', jp: '츄몬'), Word(kr: '계산', jp: '카이케이')],
  5: [Word(kr: '영수증', jp: '레시토'), Word(kr: '지폐', jp: '오사츠'), Word(kr: '동전', jp: '코인'), Word(kr: '잔돈', jp: '오츠리'), Word(kr: '카드', jp: '카도'), Word(kr: '비밀번호', jp: '안쇼방고'), Word(kr: '주소', jp: '쥬쇼'), Word(kr: '우편번호', jp: '유빈방고'), Word(kr: '편지', jp: '테가미'), Word(kr: '우표', jp: '킷테'), Word(kr: '소포', jp: '코즈츠미'), Word(kr: '짐', jp: '니모츠'), Word(kr: '가방', jp: '밧구'), Word(kr: '여권', jp: '파스포토'), Word(kr: '비자', jp: '비자'), Word(kr: '비행기표', jp: '코쿠켄'), Word(kr: '예약', jp: '요야쿠'), Word(kr: '취소', jp: '칸세루'), Word(kr: '출발', jp: '슙파츠'), Word(kr: '도착', jp: '토차쿠'), Word(kr: '지연', jp: '치엔'), Word(kr: '환승', jp: '노리카에'), Word(kr: '출구', jp: '데구치'), Word(kr: '입구', jp: '이리구치'), Word(kr: '개찰구', jp: '카이사츠구'), Word(kr: '승강장', jp: '호무'), Word(kr: '화장실', jp: '오테아라이'), Word(kr: '계단', jp: '카이단'), Word(kr: '엘리베이터', jp: '에레베타'), Word(kr: '에스컬레이터', jp: '에스카레타'), Word(kr: '위험', jp: '키켄'), Word(kr: '주의', jp: '츄이'), Word(kr: '금지', jp: '킨시'), Word(kr: '영업중', jp: '에이교츄'), Word(kr: '준비중', jp: '쥰비츄'), Word(kr: '정기휴일', jp: '테이큐비'), Word(kr: '할인', jp: '와리비키'), Word(kr: '무료', jp: '무료'), Word(kr: '유료', jp: '유료'), Word(kr: '회원', jp: '카이인'), Word(kr: '입장료', jp: '뉴죠료'), Word(kr: '안내소', jp: '안나이쇼'), Word(kr: '지도', jp: '치즈'), Word(kr: '가이드북', jp: '가이도붓쿠'), Word(kr: '렌터카', jp: '렌타카'), Word(kr: '주차장', jp: '츄샤죠'), Word(kr: '신호등', jp: '신고'), Word(kr: '교차로', jp: '코사텐'), Word(kr: '횡단보도', jp: '오단호도'), Word(kr: '육교', jp: '호도쿄')],
  6: [Word(kr: '골목', jp: '로지'), Word(kr: '지하도', jp: '치카도'), Word(kr: '건물', jp: '타테모노'), Word(kr: '빌딩', jp: '비루'), Word(kr: '아파트', jp: '만숀'), Word(kr: '맨션', jp: '아파토'), Word(kr: '주택', jp: '쥬타쿠'), Word(kr: '마을', jp: '마치'), Word(kr: '도시', jp: '토시'), Word(kr: '시골', jp: '이나카'), Word(kr: '수도', jp: '슈토'), Word(kr: '국가', jp: '코카'), Word(kr: '세계', jp: '세카이'), Word(kr: '지구', jp: '치큐'), Word(kr: '우주', jp: '우츄'), Word(kr: '자연', jp: '시젠'), Word(kr: '환경', jp: '칸쿄'), Word(kr: '공해', jp: '코가이'), Word(kr: '재해', jp: '사이가이'), Word(kr: '지진', jp: '지신'), Word(kr: '태풍', jp: '타이후'), Word(kr: '홍수', jp: '코즈이'), Word(kr: '화재', jp: '카지'), Word(kr: '사고', jp: '지코'), Word(kr: '사건', jp: '지켄'), Word(kr: '경찰', jp: '케이사츠'), Word(kr: '소방서', jp: '쇼보쇼'), Word(kr: '구급차', jp: '큐큐샤'), Word(kr: '소방차', jp: '쇼보샤'), Word(kr: '병원', jp: '쿠리닛쿠'), Word(kr: '의사', jp: '이샤'), Word(kr: '간호사', jp: '칸고시'), Word(kr: '환자', jp: '칸쟈'), Word(kr: '약', jp: '쿠스리'), Word(kr: '약국', jp: '얏쿄쿠'), Word(kr: '주사', jp: '츄샤'), Word(kr: '수술', jp: '슈쥬츠'), Word(kr: '입원', jp: '뉴인'), Word(kr: '퇴원', jp: '타이인'), Word(kr: '감기', jp: '카제(질병)'), Word(kr: '열', jp: '네츠'), Word(kr: '기침', jp: '세키'), Word(kr: '두통', jp: '즈츠'), Word(kr: '복통', jp: '후쿠츠'), Word(kr: '치통', jp: '시츠'), Word(kr: '상처', jp: '키즈'), Word(kr: '피', jp: '치'), Word(kr: '눈물', jp: '나미다'), Word(kr: '땀', jp: '아세'), Word(kr: '침', jp: '츠바')],
  7: [Word(kr: '콧물', jp: '하나미즈'), Word(kr: '목', jp: '노도'), Word(kr: '어깨', jp: '카타'), Word(kr: '등', jp: '세나카'), Word(kr: '허리', jp: '코시'), Word(kr: '배', jp: '오나카'), Word(kr: '가슴', jp: '무네'), Word(kr: '팔', jp: '우데'), Word(kr: '다리', jp: '아시(전체)'), Word(kr: '무릎', jp: '히자'), Word(kr: '발가락', jp: '아시노유비'), Word(kr: '손가락', jp: '유비'), Word(kr: '손톱', jp: '츠메'), Word(kr: '머리카락', jp: '카미'), Word(kr: '얼굴', jp: '카오'), Word(kr: '이마', jp: '히타이'), Word(kr: '눈썹', jp: '마유게'), Word(kr: '코', jp: '하나(신체)'), Word(kr: '뺨', jp: '호호'), Word(kr: '턱', jp: '아고'), Word(kr: '수염', jp: '히게'), Word(kr: '피부', jp: '하다'), Word(kr: '뼈', jp: '호네'), Word(kr: '근육', jp: '킨니쿠'), Word(kr: '심장', jp: '신조'), Word(kr: '위', jp: '이'), Word(kr: '장', jp: '쵸'), Word(kr: '간', jp: '칸조'), Word(kr: '신장', jp: '진조'), Word(kr: '폐', jp: '하이'), Word(kr: '숨', jp: '이키'), Word(kr: '목소리', jp: '코에'), Word(kr: '말', jp: '코토바'), Word(kr: '대화', jp: '카이와'), Word(kr: '이야기', jp: '하나시'), Word(kr: '질문', jp: '시츠몬'), Word(kr: '대답', jp: '코타에'), Word(kr: '부탁', jp: '오네가이'), Word(kr: '약속', jp: '야쿠소쿠'), Word(kr: '거짓말', jp: '우소'), Word(kr: '진실', jp: '신지츠'), Word(kr: '비밀', jp: '히미츠'), Word(kr: '농담', jp: '죠단'), Word(kr: '변명', jp: '이와케'), Word(kr: '사과(사죄)', jp: '아야마리'), Word(kr: '칭찬', jp: '호메코토바'), Word(kr: '욕', jp: '와루구치'), Word(kr: '불만', jp: '후만'), Word(kr: '의견', jp: '이켄'), Word(kr: '생각', jp: '칸가에')],
  8: [Word(kr: '기억', jp: '키오쿠'), Word(kr: '추억', jp: '오모이데'), Word(kr: '꿈', jp: '유메'), Word(kr: '희망', jp: '키보'), Word(kr: '절망', jp: '제츠보'), Word(kr: '행복', jp: '코후쿠'), Word(kr: '불행', jp: '후코'), Word(kr: '사랑', jp: '코이'), Word(kr: '우정', jp: '유죠'), Word(kr: '평화', jp: '헤이와'), Word(kr: '전쟁', jp: '센소'), Word(kr: '승리', jp: '쇼리'), Word(kr: '패배', jp: '하이보쿠'), Word(kr: '성공', jp: '세이코'), Word(kr: '실패', jp: '십파이'), Word(kr: '도전', jp: '쵸센'), Word(kr: '포기', jp: '아키라메'), Word(kr: '노력', jp: '도료쿠'), Word(kr: '게으름', jp: '나마케'), Word(kr: '자신감', jp: '지신(마음)'), Word(kr: '불안', jp: '후안'), Word(kr: '공포', jp: '쿄후'), Word(kr: '분노', jp: '이카리'), Word(kr: '슬픔', jp: '카나시미'), Word(kr: '기쁨', jp: '요로코비'), Word(kr: '즐거움', jp: '타노시미'), Word(kr: '웃음', jp: '와라이'), Word(kr: '울음', jp: '나키'), Word(kr: '시작', jp: '하지마리'), Word(kr: '끝', jp: '오와리'), Word(kr: '과거', jp: '카코'), Word(kr: '현재', jp: '겐자이'), Word(kr: '미래', jp: '미라이'), Word(kr: '역사', jp: '레키시'), Word(kr: '문화', jp: '분카'), Word(kr: '예술', jp: '게이쥬츠'), Word(kr: '과학', jp: '카가쿠'), Word(kr: '기술', jp: '기쥬츠'), Word(kr: '정치', jp: '세이지'), Word(kr: '경제', jp: '케이자이'), Word(kr: '사회', jp: '샤카이'), Word(kr: '법률', jp: '호리츠'), Word(kr: '종교', jp: '슈쿄'), Word(kr: '교육', jp: '쿄이쿠'), Word(kr: '스포츠', jp: '스포츠'), Word(kr: '게임', jp: '게무'), Word(kr: '장난감', jp: '오모챠'), Word(kr: '인형', jp: '닝교'), Word(kr: '로봇', jp: '로봇토'), Word(kr: '퍼즐', jp: '파즈루')],
  9: [Word(kr: '카드게임', jp: '카도게무'), Word(kr: '체스', jp: '체스'), Word(kr: '바둑', jp: '이고'), Word(kr: '장기', jp: '쇼기'), Word(kr: '주사위', jp: '사이코로'), Word(kr: '가위바위보', jp: '쟝켄'), Word(kr: '이기다', jp: '카츠'), Word(kr: '지다', jp: '마케루'), Word(kr: '비기다', jp: '히키와케루'), Word(kr: '놀다', jp: '아소부'), Word(kr: '쉬다', jp: '야스무'), Word(kr: '일하다', jp: '하타라쿠'), Word(kr: '공부하다', jp: '벤쿄스루'), Word(kr: '배우다', jp: '마나부'), Word(kr: '가르치다', jp: '오시에루'), Word(kr: '알다', jp: '시루'), Word(kr: '기억하다', jp: '오보에루'), Word(kr: '잊다', jp: '와스레루'), Word(kr: '생각하다', jp: '칸가에루'), Word(kr: '믿다', jp: '신지루'), Word(kr: '의심하다', jp: '우타가우'), Word(kr: '결정하다', jp: '키메루'), Word(kr: '선택하다', jp: '에라부'), Word(kr: '찾다', jp: '사가스'), Word(kr: '발견하다', jp: '미츠케루'), Word(kr: '잃어버리다', jp: '나쿠스'), Word(kr: '떨어뜨리다', jp: '오토스'), Word(kr: '줍다', jp: '히로우'), Word(kr: '버리다', jp: '스테루'), Word(kr: '모으다', jp: '아츠메루'), Word(kr: '나누다', jp: '와케루'), Word(kr: '주다', jp: '아게루'), Word(kr: '받다', jp: '모라우'), Word(kr: '빌려주다', jp: '카스'), Word(kr: '빌리다', jp: '카리루'), Word(kr: '돌려주다', jp: '카에스'), Word(kr: '돕다', jp: '테츠다우'), Word(kr: '방해하다', jp: '쟈마스루'), Word(kr: '기다리다', jp: '마츠'), Word(kr: '서두르다', jp: '이소구'), Word(kr: '멈추다', jp: '토마루'), Word(kr: '움직이다', jp: '우고쿠'), Word(kr: '걷다', jp: '아루쿠'), Word(kr: '달리다', jp: '하시루'), Word(kr: '뛰다', jp: '토부'), Word(kr: '수영하다', jp: '오요구'), Word(kr: '타다', jp: '노루'), Word(kr: '내리다', jp: '오리루'), Word(kr: '오르다', jp: '노보루'), Word(kr: '내려가다', jp: '쿠다루')],
  10: [Word(kr: '들어가다', jp: '하이루'), Word(kr: '나가다', jp: '데루'), Word(kr: '돌아오다', jp: '카에루'), Word(kr: '돌다', jp: '마와루'), Word(kr: '건너다', jp: '와타루'), Word(kr: '지나가다', jp: '토루'), Word(kr: '앉다', jp: '스와루'), Word(kr: '서다', jp: '타츠'), Word(kr: '눕다', jp: '요코니나루'), Word(kr: '자르다', jp: '키루'), Word(kr: '붙이다', jp: '하루'), Word(kr: '그리다', jp: '카쿠(그림)'), Word(kr: '만들다', jp: '츠쿠루'), Word(kr: '고치다', jp: '나오스'), Word(kr: '부수다', jp: '코와스'), Word(kr: '씻다', jp: '아라우'), Word(kr: '닦다', jp: '후쿠'), Word(kr: '열다', jp: '아케루'), Word(kr: '닫다', jp: '시메루'), Word(kr: '켜다', jp: '츠케루'), Word(kr: '끄다', jp: '케스'), Word(kr: '밀다', jp: '오스'), Word(kr: '당기다', jp: '히쿠'), Word(kr: '들다', jp: '모츠'), Word(kr: '놓다', jp: '오쿠'), Word(kr: '입다', jp: '키루(옷)'), Word(kr: '벗다', jp: '누구'), Word(kr: '신다', jp: '하쿠'), Word(kr: '쓰다(모자)', jp: '카부루'), Word(kr: '치다', jp: '우츠'), Word(kr: '차다', jp: '케루'), Word(kr: '던지다', jp: '나게루'), Word(kr: '잡다', jp: '츠카무'), Word(kr: '놓치다', jp: '니가스'), Word(kr: '만지다', jp: '사와루'), Word(kr: '느끼다', jp: '칸지루'), Word(kr: '냄새맡다', jp: '카구'), Word(kr: '맛보다', jp: '아지와우'), Word(kr: '살다', jp: '스무'), Word(kr: '죽다', jp: '시누'), Word(kr: '태어나다', jp: '우마레루'), Word(kr: '자라다', jp: '소다츠'), Word(kr: '늙다', jp: '오이루'), Word(kr: '젊다', jp: '와카이'), Word(kr: '아름답다', jp: '우츠쿠시이'), Word(kr: '훌륭하다', jp: '스바라시이'), Word(kr: '이상하다', jp: '오카시이'), Word(kr: '재미있다', jp: '오모시로이'), Word(kr: '지루하다', jp: '츠마라나이'), Word(kr: '놀랍다', jp: '오도로쿠')]
};

List<Word> allWords = [];
List<Word> unknownWords = [];
List<Word> completedWords = [];
int currentUnlockedLevel = 0;

Future<void> loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // 공용 사전(중앙 DB) 스캔 및 생성
  final dictDoc = await FirebaseFirestore.instance.collection('dictionary').doc('basic').get();
  Map<String, String> centralDictionary = {};
  
  if (dictDoc.exists) {
    final dictList = dictDoc.data()!['words'] as List;
    for (var item in dictList) {
      centralDictionary[item['kr']] = item['jp'];
    }
  } else {
    // 공용 사전이 없다면 600개 전체 단어를 중앙 DB에 저장
    List<Map<String, String>> allDictWords = [];
    
    for (var w in defaultWords) {
      centralDictionary[w.kr] = w.jp;
      allDictWords.add({'kr': w.kr, 'jp': w.jp});
    }
    for (var list in packageWords.values) {
      for (var w in list) {
        centralDictionary[w.kr] = w.jp;
        allDictWords.add({'kr': w.kr, 'jp': w.jp});
      }
    }
    await FirebaseFirestore.instance.collection('dictionary').doc('basic').set({
      'words': allDictWords
    });
  }

  // 유저의 개인 학습 기록 불러오기
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  
  if (doc.exists) {
    final data = doc.data()!;
    allWords = (data['allWords'] as List).map((e) => Word.fromJson(e)).toList();
    unknownWords = (data['unknownWords'] as List).map((e) => Word.fromJson(e)).toList();
    completedWords = (data['completedWords'] as List).map((e) => Word.fromJson(e)).toList();
    currentUnlockedLevel = data['unlockedLevel'] ?? 0;

    // 공용 사전을 바탕으로 유저 단어장의 오타나 발음을 자동으로 고쳐줍니다 (동기화)
    void syncPronunciation(List<Word> list) {
      for (var word in list) {
        if (centralDictionary.containsKey(word.kr)) {
          word.jp = centralDictionary[word.kr]!; 
        }
      }
    }
    syncPronunciation(allWords);
    syncPronunciation(unknownWords);
    syncPronunciation(completedWords);
    
    await saveUserData();

  } else {
    // 완전 신규 가입자인 경우 공용 사전을 바탕으로 100개 세팅
    allWords = defaultWords.map((w) => Word(kr: w.kr, jp: centralDictionary[w.kr] ?? w.jp)).toList();
    unknownWords = [];
    completedWords = [];
    currentUnlockedLevel = 0;
    await saveUserData();
  }
}

Future<void> saveUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'allWords': allWords.map((w) => w.toJson()).toList(),
    'unknownWords': unknownWords.map((w) => w.toJson()).toList(),
    'completedWords': completedWords.map((w) => w.toJson()).toList(),
    'unlockedLevel': currentUnlockedLevel,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF5F5DC)),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward().then((_) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: const Text('일본어 첫걸음', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
            future: loadUserData(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return const HomeScreen();
            }
          );
        }
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text, password: _password.text);
    } catch (e) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _password.text);
      } catch (e) {}
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
            TextField(controller: _email, decoration: const InputDecoration(labelText: '이메일 (임의 작성 가능)')),
            TextField(controller: _password, decoration: const InputDecoration(labelText: '비밀번호 (6자리 이상)'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('시작하기'))
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigate(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('일본어 학습', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(250, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    if (allWords.length <= 20) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text('현재 단어장의 단어가 20개 이하입니다.\n단어 패키지를 해제하세요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
                        )
                      );
                    } else {
                      _navigate(const QuizScreen(quizType: 'random'));
                    }
                  },
                  child: const Text('시험보기', style: TextStyle(fontSize: 20, color: Colors.white))
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(250, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _navigate(const WordListScreen()),
                  child: const Text('단어장', style: TextStyle(fontSize: 20, color: Colors.white))
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(250, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _navigate(const UnknownWordsScreen()),
                  child: const Text('모르는 단어', style: TextStyle(fontSize: 20, color: Colors.white))
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(250, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _navigate(const PackageScreen()),
                  child: const Text('단어 패키지', style: TextStyle(fontSize: 20, color: Colors.white))
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, minimumSize: const Size(250, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _navigate(const CompletedWordsScreen()),
                  child: const Text('완료한 단어', style: TextStyle(fontSize: 20, color: Colors.white))
              ),
              const SizedBox(height: 25),
              Text('현재 ${completedWords.length}개의 단어를 마스터하셨습니다!', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});
  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final _krController = TextEditingController();
  final _jpController = TextEditingController();

  void _addWord() {
    if (_krController.text.trim().isNotEmpty && _jpController.text.trim().isNotEmpty) {
      setState(() {
        allWords.add(Word(kr: _krController.text.trim(), jp: _jpController.text.trim().replaceAll('-', '')));
        saveUserData();
        _krController.clear();
        _jpController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('한국어와 일본어를 모두 입력해주세요.')));
    }
  }

  void _deleteWord(int index) {
    setState(() {
      Word wordToMove = allWords[index];
      allWords.removeAt(index);
      unknownWords.removeWhere((w) => w.kr == wordToMove.kr && w.jp == wordToMove.jp);
      completedWords.add(wordToMove);
      saveUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('단어장'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            width: double.infinity,
            color: Colors.brown.shade50,
            child: const Text(
              '* 단어장 시험에서 한 번에 맞춘 횟수가 5번인 단어는 완료한 단어로 자동 이동합니다.\n* 단어 옆 삭제를 누르면 완료한 단어로 바로 이동합니다.',
              style: TextStyle(color: Colors.brown, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _krController, decoration: const InputDecoration(hintText: '한국어'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _jpController, decoration: const InputDecoration(hintText: '일본어'))),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _addWord, child: const Text('추가'))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allWords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${allWords[index].kr} : ${allWords[index].jp}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _deleteWord(index),
                    child: const Text('삭제', style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UnknownWordsScreen extends StatefulWidget {
  const UnknownWordsScreen({super.key});
  @override
  State<UnknownWordsScreen> createState() => _UnknownWordsScreenState();
}

class _UnknownWordsScreenState extends State<UnknownWordsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('모르는 단어 목록'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
              onPressed: () async {
                if (unknownWords.isEmpty) return;
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen(quizType: 'unknown')));
                setState(() {});
              },
              child: const Text('모르는 단어만 재시험', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
          Expanded(
            child: unknownWords.isEmpty
                ? const Center(child: Text('모르는 단어가 없습니다!'))
                : ListView.builder(
                    itemCount: unknownWords.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('${unknownWords[index].kr} : ${unknownWords[index].jp}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CompletedWordsScreen extends StatefulWidget {
  const CompletedWordsScreen({super.key});
  @override
  State<CompletedWordsScreen> createState() => _CompletedWordsScreenState();
}

class _CompletedWordsScreenState extends State<CompletedWordsScreen> {
  void _restoreWord(int index) {
    setState(() {
      Word wordToRestore = completedWords[index];
      completedWords.removeAt(index);
      allWords.add(wordToRestore);
      saveUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('완료한 단어 목록'), backgroundColor: Colors.transparent, elevation: 0),
      body: completedWords.isEmpty
          ? const Center(child: Text('아직 마스터한 단어가 없습니다.'))
          : ListView.builder(
              itemCount: completedWords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${completedWords[index].kr} : ${completedWords[index].jp}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _restoreWord(index),
                    child: const Text('삭제', style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String quizType;
  final List<Word>? customWords;

  const QuizScreen({super.key, required this.quizType, this.customWords});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<Word> _currentQuizData = [];
  List<Word> _currentSessionIncorrect = [];
  List<Word> _masteredThisSession = [];
  int _currentIndex = 0;
  bool _isFirstTry = true;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _startQuizData();
  }

  void _startQuizData() {
    if (widget.quizType == 'random') {
      _currentQuizData = List.from(allWords)..shuffle();
      _currentQuizData = _currentQuizData.take(20).toList();
    } else if (widget.quizType == 'unknown') {
      _currentQuizData = List.from(unknownWords)..shuffle();
      _currentQuizData = _currentQuizData.take(20).toList();
    } else if (widget.quizType == 'retry' && widget.customWords != null) {
      _currentQuizData = List.from(widget.customWords!);
    }
  }

  void _checkAnswer(String val) {
    Word currentWord = _currentQuizData[_currentIndex];
    
    if (val.trim() == currentWord.jp) {
      if (_isFirstTry && widget.quizType != 'retry') {
        unknownWords.removeWhere((w) => w.kr == currentWord.kr && w.jp == currentWord.jp);
        
        currentWord.correctCount++;
        if (currentWord.correctCount >= 5) {
          allWords.removeWhere((w) => w.kr == currentWord.kr && w.jp == currentWord.jp);
          if (!completedWords.any((w) => w.kr == currentWord.kr && w.jp == currentWord.jp)) {
            currentWord.correctCount = 0;
            completedWords.add(currentWord);
            _masteredThisSession.add(currentWord);
          }
        }
      }
      saveUserData();
      setState(() {
        _currentIndex++;
        _isFirstTry = true;
        _showError = false;
        _textController.clear();
      });
    } else {
      if (_showError) return; 

      if (_isFirstTry) {
        if (widget.quizType != 'retry') {
          if (!unknownWords.any((w) => w.kr == currentWord.kr && w.jp == currentWord.jp)) {
            unknownWords.add(currentWord);
          }
          currentWord.correctCount = 0;
        }
        _currentSessionIncorrect.add(currentWord);
        _isFirstTry = false;
        saveUserData();
      }
      setState(() {
        _showError = true;
        _textController.clear();
      });
    }
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
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
        resultChildren.add(const Text('★한 번에 맞추기 5회 성공★', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
        resultChildren.add(const SizedBox(height: 10));
        for (var word in _masteredThisSession) {
          resultChildren.add(
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.black),
                children: [
                  TextSpan(text: '${word.kr}(${word.jp})', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue)),
                  const TextSpan(text: '가 완료한 단어로 이동하였습니다.'),
                ]
              )
            )
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
          )
        );
        resultChildren.add(const SizedBox(height: 15));
      }

      resultChildren.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
          onPressed: () => Navigator.pop(context),
          child: const Text('종료하기', style: TextStyle(fontSize: 20, color: Colors.white)),
        )
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

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${_currentIndex + 1} / ${_currentQuizData.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text('한국어: ${currentWord.kr}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
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
                    onSubmitted: _checkAnswer,
                    decoration: InputDecoration(
                      hintText: _showError ? currentWord.jp : '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _showError ? Colors.red : Colors.grey, width: 2)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _showError ? Colors.red : Colors.grey, width: 2)
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});
  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void _unlock(int targetLevel) {
    if (allWords.length > 50) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('해제 불가', textAlign: TextAlign.center),
          content: Text(
            '단어 패키지는 학습중인 단어장의 단어가 50개 이하일 때 가능합니다.\n\n현재 학습중인 단어는 ${allWords.length}개입니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
        )
      );
      return;
    }

    _confettiController.play();
    setState(() {
      currentUnlockedLevel = targetLevel;
      if (packageWords.containsKey(targetLevel)) {
        for (var w in packageWords[targetLevel]!) {
          allWords.add(Word(kr: w.kr, jp: w.jp));
        }
      }
    });
    saveUserData();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('축하합니다', textAlign: TextAlign.center),
        content: Text('$targetLevel살 생일 축하합니다\n(새 단어 50개가 단어장에 추가되었습니다!)', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('단어 패키지'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              int level = index + 1;
              bool isUnlocked = level <= currentUnlockedLevel;
              bool isNextToUnlock = level == currentUnlockedLevel + 1;
              return ListTile(
                leading: Icon(isUnlocked ? Icons.lock_open : Icons.lock),
                title: Text('$level살 단어'),
                trailing: isNextToUnlock 
                  ? ElevatedButton(onPressed: () => _unlock(level), child: const Text('해제하기')) 
                  : null,
              );
            }
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple],
            )
          )
        ],
      )
    );
  }
}