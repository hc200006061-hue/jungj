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

final List<Word> defaultWords = [
  Word(kr: '나', jp: '와타시'), Word(kr: '너', jp: '아나타'), Word(kr: '우리', jp: '와타시타치'), Word(kr: '이것', jp: '코레'), Word(kr: '그것', jp: '소레'), Word(kr: '저것', jp: '아레'), Word(kr: '여기', jp: '코코'), Word(kr: '거기', jp: '소코'), Word(kr: '저기', jp: '아소코'), Word(kr: '누구', jp: '다레'), Word(kr: '무엇', jp: '나니'), Word(kr: '어디', jp: '도코'), Word(kr: '언제', jp: '이츠'), Word(kr: '왜', jp: '나제'), Word(kr: '어떻게', jp: '도오얏테'), Word(kr: '안녕하세요', jp: '콘니치와'), Word(kr: '안녕히계세요', jp: '사요오나라'), Word(kr: '감사합니다', jp: '아리가토오'), Word(kr: '죄송합니다', jp: '스미마셍'), Word(kr: '네', jp: '하이'), Word(kr: '아니요', jp: '이이에'), Word(kr: '괜찮습니다', jp: '다이죠오부데스'), Word(kr: '수고하셨습니다', jp: '오츠카레사마데시타'), Word(kr: '오늘', jp: '쿄오'), Word(kr: '내일', jp: '아시타'), Word(kr: '어제', jp: '키노오'), Word(kr: '지금', jp: '이마'), Word(kr: '아침', jp: '아사'), Word(kr: '점심', jp: '히루'), Word(kr: '저녁', jp: '요루'), Word(kr: '매일', jp: '마이니치'), Word(kr: '시간', jp: '지캉'), Word(kr: '시', jp: '지'), Word(kr: '분', jp: '붕'), Word(kr: '사람', jp: '히토'), Word(kr: '남자', jp: '오토코'), Word(kr: '여자', jp: '온나'), Word(kr: '친구', jp: '토모다치'), Word(kr: '가족', jp: '카조쿠'), Word(kr: '이름', jp: '나마에'), Word(kr: '나라', jp: '쿠니'), Word(kr: '집', jp: '이에'), Word(kr: '방', jp: '헤야'), Word(kr: '문', jp: '도아'), Word(kr: '창문', jp: '마도'), Word(kr: '책', jp: '홍'), Word(kr: '책상', jp: '츠쿠에'), Word(kr: '의자', jp: '이스'), Word(kr: '물', jp: '미즈'), Word(kr: '밥', jp: '고항'), Word(kr: '차', jp: '오차'), Word(kr: '돈', jp: '오카네'), Word(kr: '일', jp: '시고토'), Word(kr: '학교', jp: '갓코오'), Word(kr: '회사', jp: '카이샤'), Word(kr: '병원', jp: '뵤오잉'), Word(kr: '화장실', jp: '토이레'), Word(kr: '가게', jp: '미세'), Word(kr: '길', jp: '미치'), Word(kr: '역', jp: '에키'), Word(kr: '자동차', jp: '쿠루마'), Word(kr: '전철', jp: '덴샤'), Word(kr: '비행기', jp: '히코오키'), Word(kr: '문제', jp: '몬다이'), Word(kr: '마음', jp: '코코로'), Word(kr: '몸', jp: '카라다'), Word(kr: '손', jp: '테'), Word(kr: '발', jp: '아시'), Word(kr: '눈', jp: '메'), Word(kr: '입', jp: '쿠치'), Word(kr: '귀', jp: '미미'), Word(kr: '가다', jp: '이쿠'), Word(kr: '오다', jp: '쿠루'), Word(kr: '먹다', jp: '타베루'), Word(kr: '마시다', jp: '노무'), Word(kr: '자다', jp: '네루'), Word(kr: '일어나다', jp: '오키루'), Word(kr: '보다', jp: '미루'), Word(kr: '듣다', jp: '키쿠'), Word(kr: '말하다', jp: '하나스'), Word(kr: '읽다', jp: '요무'), Word(kr: '쓰다', jp: '카쿠'), Word(kr: '사다', jp: '카우'), Word(kr: '하다', jp: '스루'), Word(kr: '모르다', jp: '시라나이'), Word(kr: '좋아하다', jp: '스키다'), Word(kr: '싫어하다', jp: '키라이다'), Word(kr: '크다', jp: '오오키이'), Word(kr: '작다', jp: '치이사이'), Word(kr: '많다', jp: '오오이'), Word(kr: '적다', jp: '스크나이'), Word(kr: '좋다', jp: '이이'), Word(kr: '나쁘다', jp: '와루이'), Word(kr: '새롭다', jp: '아타라시이'), Word(kr: '낡다', jp: '후루이'), Word(kr: '덥다', jp: '아츠이'), Word(kr: '춥다', jp: '사무이'), Word(kr: '어렵다', jp: '무즈카시이'), Word(kr: '쉽다', jp: '야사시이'), Word(kr: '지하철', jp: '치카테츠')
];

final Map<int, List<Word>> packageWords = {
  1: [Word(kr: '고기', jp: '니쿠'), Word(kr: '생선', jp: '사카나'), Word(kr: '야채', jp: '야사이'), Word(kr: '과일', jp: '쿠다모노'), Word(kr: '빵', jp: '팡'), Word(kr: '우유', jp: '규우뉴우'), Word(kr: '커피', jp: '코오히이'), Word(kr: '술', jp: '오사케'), Word(kr: '아침식사', jp: '쵸오쇼쿠'), Word(kr: '점심식사', jp: '츄우쇼쿠'), Word(kr: '저녁식사', jp: '유우쇼쿠'), Word(kr: '소금', jp: '시오'), Word(kr: '설탕', jp: '사토오'), Word(kr: '간장', jp: '쇼오유'), Word(kr: '계란', jp: '타마고'), Word(kr: '사과', jp: '링고'), Word(kr: '귤', jp: '미캉'), Word(kr: '딸기', jp: '이치고'), Word(kr: '포도', jp: '부도오'), Word(kr: '바나나', jp: '바나나'), Word(kr: '수박', jp: '스이카'), Word(kr: '시계', jp: '토케이'), Word(kr: '안경', jp: '메가네'), Word(kr: '우산', jp: '카사'), Word(kr: '가방', jp: '카방'), Word(kr: '지갑', jp: '사이후'), Word(kr: '구두', jp: '쿠츠'), Word(kr: '옷', jp: '후쿠'), Word(kr: '바지', jp: '즈봉'), Word(kr: '치마', jp: '스카아토'), Word(kr: '모자', jp: '보오시'), Word(kr: '셔츠', jp: '샤츠'), Word(kr: '양말', jp: '쿠츠시타'), Word(kr: '속옷', jp: '시타기'), Word(kr: '넥타이', jp: '네쿠타이'), Word(kr: '손수건', jp: '항카치'), Word(kr: '수건', jp: '타오루'), Word(kr: '비누', jp: '셋켕'), Word(kr: '칫솔', jp: '하부라시'), Word(kr: '치약', jp: '하미가키코'), Word(kr: '샴푸', jp: '샴푸'), Word(kr: '휴지', jp: '팃슈'), Word(kr: '쓰레기', jp: '고미'), Word(kr: '열쇠', jp: '카기'), Word(kr: '사진', jp: '샤싱'), Word(kr: '그림', jp: '에'), Word(kr: '영화', jp: '에이가'), Word(kr: '음악', jp: '옹가쿠'), Word(kr: '신문', jp: '심붕'), Word(kr: '편지', jp: '테가미')],
  2: [Word(kr: '개', jp: '이누'), Word(kr: '고양이', jp: '네코'), Word(kr: '새', jp: '토리'), Word(kr: '소', jp: '우시'), Word(kr: '돼지', jp: '부타'), Word(kr: '말', jp: '우마'), Word(kr: '원숭이', jp: '사루'), Word(kr: '곰', jp: '쿠마'), Word(kr: '호랑이', jp: '토라'), Word(kr: '사자', jp: '라이온'), Word(kr: '코끼리', jp: '조오'), Word(kr: '쥐', jp: '네즈미'), Word(kr: '뱀', jp: '헤비'), Word(kr: '벌레', jp: '무시'), Word(kr: '바다', jp: '우미'), Word(kr: '산', jp: '야마'), Word(kr: '강', jp: '카와'), Word(kr: '하늘', jp: '소라'), Word(kr: '별', jp: '호시'), Word(kr: '달', jp: '츠키'), Word(kr: '해', jp: '타이요오'), Word(kr: '구름', jp: '쿠모'), Word(kr: '비', jp: '아메'), Word(kr: '눈(날씨)', jp: '유키'), Word(kr: '바람', jp: '카제'), Word(kr: '나무', jp: '키'), Word(kr: '꽃', jp: '하나'), Word(kr: '풀', jp: '쿠사'), Word(kr: '돌', jp: '이시'), Word(kr: '땅', jp: '츠치'), Word(kr: '빛', jp: '히카리'), Word(kr: '그림자', jp: '카게'), Word(kr: '공원', jp: '코오엥'), Word(kr: '은행', jp: '깅코오'), Word(kr: '우체국', jp: '유우빙쿄쿠'), Word(kr: '경찰서', jp: '케이사츠쇼오'), Word(kr: '도서관', jp: '토쇼캉'), Word(kr: '영화관', jp: '에이가캉'), Word(kr: '식당', jp: '쇼쿠도오'), Word(kr: '카페', jp: '카페'), Word(kr: '공장', jp: '코오죠오'), Word(kr: '해변', jp: '카이강'), Word(kr: '섬', jp: '시마'), Word(kr: '숲', jp: '모리'), Word(kr: '벌판', jp: '하라'), Word(kr: '우주', jp: '우츄우'), Word(kr: '공기', jp: '쿠우키'), Word(kr: '불', jp: '히'), Word(kr: '얼음', jp: '코오리'), Word(kr: '우표', jp: '킷테')],
  3: [Word(kr: '숫자일', jp: '이치'), Word(kr: '숫자이', jp: '니'), Word(kr: '숫자삼', jp: '산'), Word(kr: '숫자사', jp: '시'), Word(kr: '숫자오', jp: '고'), Word(kr: '숫자육', jp: '로쿠'), Word(kr: '숫자칠', jp: '나나'), Word(kr: '숫자팔', jp: '하치'), Word(kr: '숫자구', jp: '큐우'), Word(kr: '숫자십', jp: '쥬우'), Word(kr: '백', jp: '햐쿠'), Word(kr: '천', jp: '셍'), Word(kr: '만', jp: '망'), Word(kr: '영', jp: '제로'), Word(kr: '첫째', jp: '다이이치'), Word(kr: '절반', jp: '항붕'), Word(kr: '봄', jp: '하루'), Word(kr: '여름', jp: '나츠'), Word(kr: '가을', jp: '아키'), Word(kr: '겨울', jp: '후유'), Word(kr: '월요일', jp: '게츠요오비'), Word(kr: '화요일', jp: '카요오비'), Word(kr: '수요일', jp: '스이요오비'), Word(kr: '목요일', jp: '모쿠요오비'), Word(kr: '금요일', jp: '킹요오비'), Word(kr: '토요일', jp: '도요오비'), Word(kr: '일요일', jp: '니치요오비'), Word(kr: '주말', jp: '슈우마츠'), Word(kr: '평일', jp: '헤이지츠'), Word(kr: '오전', jp: '고젱'), Word(kr: '오후', jp: '고고'), Word(kr: '자정', jp: '마요나카'), Word(kr: '정오', jp: '쇼오고'), Word(kr: '달력', jp: '카렌다아'), Word(kr: '계절', jp: '키세츠'), Word(kr: '세기', jp: '세에키'), Word(kr: '빨강', jp: '아카'), Word(kr: '파랑', jp: '아오'), Word(kr: '노랑', jp: '키이로'), Word(kr: '하양', jp: '시로'), Word(kr: '검정', jp: '쿠로'), Word(kr: '녹색', jp: '미도리'), Word(kr: '갈색', jp: '차이로'), Word(kr: '회색', jp: '하이이로'), Word(kr: '분홍', jp: '핑크'), Word(kr: '보라', jp: '무라사키'), Word(kr: '주황', jp: '오렌지'), Word(kr: '은색', jp: '긴이로'), Word(kr: '금색', jp: '킨이로'), Word(kr: '색깔', jp: '이로')],
  4: [Word(kr: '어머니', jp: '하하'), Word(kr: '아버지', jp: '치치'), Word(kr: '형', jp: '아니'), Word(kr: '누나', jp: '아네'), Word(kr: '남동생', jp: '오토오토'), Word(kr: '여동생', jp: '이모오토'), Word(kr: '할아버지', jp: '소후'), Word(kr: '할머니', jp: '소보'), Word(kr: '남편', jp: '옷토'), Word(kr: '아내', jp: '츠마'), Word(kr: '아들', jp: '무스코'), Word(kr: '딸', jp: '무스메'), Word(kr: '삼촌', jp: '오지'), Word(kr: '이모', jp: '오바'), Word(kr: '부모', jp: '료오싱'), Word(kr: '아이', jp: '코도모'), Word(kr: '어른', jp: '오토나'), Word(kr: '청년', jp: '와카모노'), Word(kr: '노인', jp: '로오징'), Word(kr: '손님', jp: '오캬쿠상'), Word(kr: '의사', jp: '이샤'), Word(kr: '선생님', jp: '센세에'), Word(kr: '학생', jp: '가쿠세에'), Word(kr: '경찰', jp: '케이사츠캉'), Word(kr: '군인', jp: '군징'), Word(kr: '직원', jp: '샤잉'), Word(kr: '사장', jp: '샤쵸오'), Word(kr: '가수', jp: '카슈'), Word(kr: '배우', jp: '하이유우'), Word(kr: '작가', jp: '사카'), Word(kr: '머리', jp: '아타마'), Word(kr: '머리카락', jp: '카미'), Word(kr: '얼굴', jp: '카오'), Word(kr: '코', jp: '하나'), Word(kr: '목', jp: '쿠비'), Word(kr: '어깨', jp: '카타'), Word(kr: '가슴', jp: '무네'), Word(kr: '등', jp: '세나카'), Word(kr: '배', jp: '오나카'), Word(kr: '허리', jp: '코시'), Word(kr: '엉덩이', jp: '오시리'), Word(kr: '다리', jp: '아시'), Word(kr: '무릎', jp: '히자'), Word(kr: '피부', jp: '히후'), Word(kr: '피', jp: '치'), Word(kr: '뼈', jp: '호네'), Word(kr: '눈물', jp: '나미다'), Word(kr: '땀', jp: '아세'), Word(kr: '근육', jp: '킨니쿠'), Word(kr: '신경', jp: '싱케이')],
  5: [Word(kr: '위', jp: '우에'), Word(kr: '아래', jp: '시타'), Word(kr: '앞', jp: '마에'), Word(kr: '뒤', jp: '우시로'), Word(kr: '옆', jp: '토나리'), Word(kr: '오른쪽', jp: '미기'), Word(kr: '왼쪽', jp: '히다리'), Word(kr: '안', jp: '나카'), Word(kr: '밖', jp: '소토'), Word(kr: '사이', jp: '아이다'), Word(kr: '동쪽', jp: '히가시'), Word(kr: '서쪽', jp: '니시'), Word(kr: '남쪽', jp: '미나미'), Word(kr: '북쪽', jp: '키타'), Word(kr: '걷다', jp: '아루쿠'), Word(kr: '달리다', jp: '하시루'), Word(kr: '뛰다', jp: '토부'), Word(kr: '앉다', jp: '스와루'), Word(kr: '서다', jp: '타츠'), Word(kr: '타다', jp: '노루'), Word(kr: '내리다', jp: '오리루'), Word(kr: '열다', jp: '아케루'), Word(kr: '닫다', jp: '시메루'), Word(kr: '켜다', jp: '츠케루'), Word(kr: '끄다', jp: '케스'), Word(kr: '주다', jp: '아게루'), Word(kr: '받다', jp: '모라우'), Word(kr: '빌리다', jp: '카리루'), Word(kr: '빌려주다', jp: '카스'), Word(kr: '가르치다', jp: '오시에루'), Word(kr: '배우다', jp: '나라우'), Word(kr: '일하다', jp: '하타라쿠'), Word(kr: '쉬다', jp: '야스무'), Word(kr: '놀다', jp: '아소부'), Word(kr: '만나다', jp: '아우'), Word(kr: '헤어지다', jp: '와카레루'), Word(kr: '기다리다', jp: '마츠'), Word(kr: '생각하다', jp: '캉가에루'), Word(kr: '기억하다', jp: '오보에루'), Word(kr: '잊다', jp: '와스레루'), Word(kr: '웃다', jp: '와라우'), Word(kr: '울다', jp: '나쿠'), Word(kr: '화내다', jp: '오코루'), Word(kr: '기뻐하다', jp: '요로코부'), Word(kr: '슬퍼하다', jp: '카나시무'), Word(kr: '즐기다', jp: '타노시무'), Word(kr: '노래하다', jp: '우타우'), Word(kr: '춤추다', jp: '오도루'), Word(kr: '씻다', jp: '아라우'), Word(kr: '닦다', jp: '미가쿠')],
  6: [Word(kr: '길다', jp: '나가이'), Word(kr: '짧다', jp: '미지카이'), Word(kr: '높다', jp: '타카이'), Word(kr: '낮다', jp: '히쿠이'), Word(kr: '넓다', jp: '히로이'), Word(kr: '좁다', jp: '세마이'), Word(kr: '무겁다', jp: '오모이'), Word(kr: '가볍다', jp: '카루이'), Word(kr: '빠르다', jp: '하야이'), Word(kr: '느리다', jp: '오소이'), Word(kr: '강하다', jp: '츠요이'), Word(kr: '약하다', jp: '요와이'), Word(kr: '맑다', jp: '하레루'), Word(kr: '흐리다', jp: '쿠모루'), Word(kr: '바쁘다', jp: '이소가시이'), Word(kr: '한가하다', jp: '히마다'), Word(kr: '조용하다', jp: '시즈카다'), Word(kr: '시끄럽다', jp: '우루사이'), Word(kr: '깨끗하다', jp: '키레이다'), Word(kr: '더럽다', jp: '키타나이'), Word(kr: '맛있다', jp: '오이시이'), Word(kr: '맛없다', jp: '마즈이'), Word(kr: '달다', jp: '아마이'), Word(kr: '짜다', jp: '숏파이'), Word(kr: '맵다', jp: '카라이'), Word(kr: '시다', jp: '슷파이'), Word(kr: '따뜻하다', jp: '아타타카이'), Word(kr: '서늘하다', jp: '스즈시이'), Word(kr: '아프다', jp: '이타이'), Word(kr: '피곤하다', jp: '츠카레루'), Word(kr: '졸리다', jp: '네무이'), Word(kr: '무섭다', jp: '코와이'), Word(kr: '부끄럽다', jp: '하즈카시이'), Word(kr: '부럽다', jp: '우라야마시이'), Word(kr: '그립다', jp: '나츠카시이'), Word(kr: '심심하다', jp: '타이쿠츠다'), Word(kr: '이상하다', jp: '오카시이'), Word(kr: '귀엽다', jp: '카와이이'), Word(kr: '아름답다', jp: '우츠쿠시이'), Word(kr: '멋지다', jp: '캇코이이'), Word(kr: '친절하다', jp: '신세츠다'), Word(kr: '유명하다', jp: '유우메에다'), Word(kr: '안전하다', jp: '안젱다'), Word(kr: '위험하다', jp: '키켕다'), Word(kr: '중요하다', jp: '타이세츠다'), Word(kr: '필요하다', jp: '히츠요오다'), Word(kr: '충분하다', jp: '쥬우붕다'), Word(kr: '훌륭하다', jp: '스바라시이'), Word(kr: '끔찍하다', jp: '히도이'), Word(kr: '기차', jp: '키샤')],
  7: [Word(kr: '가위', jp: '하사미'), Word(kr: '접착제', jp: '노리'), Word(kr: '자', jp: '죠오기'), Word(kr: '지우개', jp: '케시고무'), Word(kr: '연필', jp: '엠피츠'), Word(kr: '볼펜', jp: '보오루펭'), Word(kr: '공책', jp: '노오토'), Word(kr: '편지봉투', jp: '후우토오'), Word(kr: '상자', jp: '하코'), Word(kr: '바늘', jp: '하리'), Word(kr: '실', jp: '이토'), Word(kr: '칼', jp: '나이후'), Word(kr: '그릇', jp: '우츠와'), Word(kr: '접시', jp: '사라'), Word(kr: '젓가락', jp: '하시'), Word(kr: '숟가락', jp: '스푸웅'), Word(kr: '냄비', jp: '나베'), Word(kr: '프라이팬', jp: '후라이팡'), Word(kr: '냉장고', jp: '레이조오코'), Word(kr: '세탁기', jp: '센타쿠키'), Word(kr: '청소기', jp: '소오지키'), Word(kr: '에어컨', jp: '에아콩'), Word(kr: '선풍기', jp: '센푸우키'), Word(kr: '난로', jp: '스토오부'), Word(kr: '텔레비전', jp: '테레비'), Word(kr: '컴퓨터', jp: '콘퓨우타아'), Word(kr: '전화기', jp: '덴와'), Word(kr: '스마트폰', jp: '스마호'), Word(kr: '배터리', jp: '덴치'), Word(kr: '케이블', jp: '케에부루'), Word(kr: '침대', jp: '벳도'), Word(kr: '이불', jp: '후통'), Word(kr: '베개', jp: '마쿠라'), Word(kr: '거울', jp: '카가미'), Word(kr: '빗', jp: '쿠시'), Word(kr: '드라이기', jp: '도라이야아'), Word(kr: '화장품', jp: '케쇼오힝'), Word(kr: '향수', jp: '코오스이'), Word(kr: '비상약', jp: '히죠오야쿠'), Word(kr: '연고', jp: '낭코오'), Word(kr: '반창고', jp: '반소오코오'), Word(kr: '가구', jp: '카구'), Word(kr: '소파', jp: '소후아'), Word(kr: '책장', jp: '혼다나'), Word(kr: '옷장', jp: '탄스'), Word(kr: '장난감', jp: '오모차'), Word(kr: '인형', jp: '닝교오'), Word(kr: '게임기', jp: '게에무키'), Word(kr: '자전거', jp: '지텐샤'), Word(kr: '오토바이', jp: '오오토바이')],
  8: [Word(kr: '돕다', jp: '타스케루'), Word(kr: '살리다', jp: '이카스'), Word(kr: '죽다', jp: '시누'), Word(kr: '태어나다', jp: '우마레루'), Word(kr: '살다', jp: '스무'), Word(kr: '이사하다', jp: '힛코시스루'), Word(kr: '결혼하다', jp: '켁콘스루'), Word(kr: '이혼하다', jp: '리콩스루'), Word(kr: '약속하다', jp: '야쿠소쿠스루'), Word(kr: '사과하다', jp: '아야마루'), Word(kr: '용서하다', jp: '유루스'), Word(kr: '싸우다', jp: '타타카우'), Word(kr: '이기다', jp: '카츠'), Word(kr: '지다', jp: '마케루'), Word(kr: '포기하다', jp: '아키라메루'), Word(kr: '계속하다', jp: '츠즈케루'), Word(kr: '그만두다', jp: '야메루'), Word(kr: '변하다', jp: '카와루'), Word(kr: '바꾸다', jp: '카에루'), Word(kr: '고치다', jp: '나오스'), Word(kr: '부수다', jp: '코와스'), Word(kr: '만들다', jp: '츠쿠루'), Word(kr: '사용하다', jp: '츠카우'), Word(kr: '찾다', jp: '사가스'), Word(kr: '발견하다', jp: '미츠케루'), Word(kr: '잃어버리다', jp: '나쿠스'), Word(kr: '떨어지다', jp: '오치루'), Word(kr: '떨어뜨리다', jp: '오토스'), Word(kr: '던지다', jp: '나게루'), Word(kr: '잡다', jp: '츠카무'), Word(kr: '밀다', jp: '오스'), Word(kr: '당기다', jp: '히쿠'), Word(kr: '자르다', jp: '키루'), Word(kr: '붙이다', jp: '하루'), Word(kr: '섞다', jp: '마제루'), Word(kr: '나누다', jp: '와케루'), Word(kr: '모으다', jp: '아츠메루'), Word(kr: '늘다', jp: '후에루'), Word(kr: '줄다', jp: '헤루'), Word(kr: '남다', jp: '노코루'), Word(kr: '끝나다', jp: '오와루'), Word(kr: '시작하다', jp: '하지마루'), Word(kr: '성공하다', jp: '세이코오스루'), Word(kr: '실패하다', jp: '싯파이스루'), Word(kr: '합격하다', jp: '고오카쿠스루'), Word(kr: '불합격하다', jp: '후고오카쿠스루'), Word(kr: '취직하다', jp: '슈우쇼쿠스루'), Word(kr: '퇴사하다', jp: '타이샤스루'), Word(kr: '출장가다', jp: '슛쵸오스루'), Word(kr: '지각하다', jp: '치코쿠스루')],
  9: [Word(kr: '경제', jp: '케이자이'), Word(kr: '정치', jp: '세이지'), Word(kr: '사회', jp: '샤카이'), Word(kr: '문화', jp: '붕카'), Word(kr: '역사', jp: '레키시'), Word(kr: '지리', jp: '치리'), Word(kr: '과학', jp: '카가쿠'), Word(kr: '기술', jp: '기쥬츠'), Word(kr: '정보', jp: '죠오호오'), Word(kr: '통신', jp: '츠우싱'), Word(kr: '자연', jp: '시젱'), Word(kr: '환경', jp: '캉쿄오'), Word(kr: '평화', jp: '헤이와'), Word(kr: '전쟁', jp: '센소오'), Word(kr: '군대', jp: '군타이'), Word(kr: '법', jp: '호오리츠'), Word(kr: '규칙', jp: '키소쿠'), Word(kr: '자유', jp: '지유우'), Word(kr: '평등', jp: '뵤오도오'), Word(kr: '권리', jp: '켄리'), Word(kr: '의무', jp: '기무'), Word(kr: '책임', jp: '세키닝'), Word(kr: '노력', jp: '도료쿠'), Word(kr: '목표', jp: '모쿠효오'), Word(kr: '계획', jp: '케이카쿠'), Word(kr: '결과', jp: '켓카'), Word(kr: '원인', jp: '겐잉'), Word(kr: '이유', jp: '리유우'), Word(kr: '의미', jp: '이미'), Word(kr: '가치', jp: '카치'), Word(kr: '가격', jp: '카카쿠'), Word(kr: '세금', jp: '제이킹'), Word(kr: '월급', jp: '큐우료오'), Word(kr: '보너스', jp: '보오나스'), Word(kr: '물가', jp: '붓카'), Word(kr: '환율', jp: '카와세'), Word(kr: '주식', jp: '카부시키'), Word(kr: '투자', jp: '토시'), Word(kr: '저축', jp: '초치쿠'), Word(kr: '빚', jp: '샷킹'), Word(kr: '이자', jp: '리시'), Word(kr: '보험', jp: '호켕'), Word(kr: '계약', jp: '케이야쿠'), Word(kr: '서류', jp: '쇼루이'), Word(kr: '회의', jp: '카이기'), Word(kr: '면접', jp: '멘세츠'), Word(kr: '발표', jp: '핫표오'), Word(kr: '의견', jp: '이켕'), Word(kr: '찬성', jp: '산세에'), Word(kr: '반대', jp: '한타이')],
  10: [Word(kr: '여행', jp: '료코오'), Word(kr: '여권', jp: '료켕'), Word(kr: '비자', jp: '비자'), Word(kr: '비행기표', jp: '코오쿠우켕'), Word(kr: '공항', jp: '쿠우코오'), Word(kr: '수하물', jp: '테니모츠'), Word(kr: '예약', jp: '요야쿠'), Word(kr: '취소', jp: '토리케시'), Word(kr: '숙소', jp: '야도'), Word(kr: '호텔', jp: '호테루'), Word(kr: '프런트', jp: '후론토'), Word(kr: '영수증', jp: '료오슈우쇼'), Word(kr: '잔돈', jp: '오츠리'), Word(kr: '환전', jp: '료가에'), Word(kr: '지도', jp: '치즈'), Word(kr: '안내소', jp: '안나이쇼'), Word(kr: '관광', jp: '캉코오'), Word(kr: '기념품', jp: '오미야게'), Word(kr: '온천', jp: '온셍'), Word(kr: '신사', jp: '진쟈'), Word(kr: '절', jp: '테라'), Word(kr: '성', jp: '시로'), Word(kr: '유적', jp: '이세키'), Word(kr: '축제', jp: '마츠리'), Word(kr: '벚꽃', jp: '사쿠라'), Word(kr: '단풍', jp: '모미지'), Word(kr: '불꽃놀이', jp: '하나비'), Word(kr: '만화', jp: '망가'), Word(kr: '애니메이션', jp: '아니메'), Word(kr: '소설', jp: '쇼오세츠'), Word(kr: '잡지', jp: '잣시'), Word(kr: '방송', jp: '호오소오'), Word(kr: '뉴스', jp: '뉴스'), Word(kr: '광고', jp: '코오코쿠'), Word(kr: '기사', jp: '키지'), Word(kr: '사건', jp: '지켕'), Word(kr: '사고', jp: '지코'), Word(kr: '범죄', jp: '한자이'), Word(kr: '경찰차', jp: '파토카아'), Word(kr: '구급차', jp: '큐우큐우샤'), Word(kr: '소방차', jp: '쇼오보오샤'), Word(kr: '지진', jp: '지싱'), Word(kr: '화산', jp: '카장'), Word(kr: '홍수', jp: '코오즈이'), Word(kr: '태풍', jp: '타이후우'), Word(kr: '피해', jp: '히가이'), Word(kr: '구조', jp: '큐우죠오'), Word(kr: '생명', jp: '이노치'), Word(kr: '미래', jp: '미라이'), Word(kr: '과거', jp: '카코')],
};

List<Word> allWords = [];
List<Word> unknownWords = [];
List<Word> completedWords = [];
int currentUnlockedLevel = 0;
bool isTutorialCompleted = false;

Future<void> loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final dictDoc = await FirebaseFirestore.instance.collection('dictionary').doc('basic').get();
  Map<String, String> centralDictionary = {};
  
  if (dictDoc.exists) {
    final dictList = dictDoc.data()!['words'] as List;
    for (var item in dictList) {
      centralDictionary[item['kr']] = item['jp'];
    }
  } else {
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

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  
  if (doc.exists) {
    final data = doc.data()!;
    allWords = (data['allWords'] as List).map((e) => Word.fromJson(e)).toList();
    unknownWords = (data['unknownWords'] as List).map((e) => Word.fromJson(e)).toList();
    completedWords = (data['completedWords'] as List).map((e) => Word.fromJson(e)).toList();
    currentUnlockedLevel = data['unlockedLevel'] ?? 0;
    isTutorialCompleted = data['tutorialCompleted'] ?? false;

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
    allWords = defaultWords.map((w) => Word(kr: w.kr, jp: centralDictionary[w.kr] ?? w.jp)).toList();
    unknownWords = [];
    completedWords = [];
    currentUnlockedLevel = 0;
    isTutorialCompleted = false;
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
    'tutorialCompleted': isTutorialCompleted,
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _login() async {
    if (!_isValidEmail(_email.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이메일 형식이 올바르지 않습니다.')));
      return;
    }
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text, password: _password.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _password.text);
        } on FirebaseAuthException catch (createError) {
          if (createError.code == 'email-already-in-use') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호가 틀립니다.')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 실패')));
          }
        }
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호가 틀립니다.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('오류가 발생했습니다.')));
      }
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
  @override
  void initState() {
    super.initState();
    if (!isTutorialCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showManualDialog(isFirstTime: true);
      });
    }
  }

  void _showManualDialog({bool isFirstTime = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isFirstTime,
      builder: (context) => AlertDialog(
        title: const Text('앱 이용 안내', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            '원활한 학습을 위해 핵심 기능을 간단히 안내해 드립니다.\n\n'
            '• 시험보기: 단어장의 단어 중 무작위로 출제됩니다. 정답을 알맞게 입력하면 엔터를 치지 않아도 자동으로 다음 문제로 넘어갑니다. (오답인 경우 엔터를 누르면 정답이 표시됩니다.) 오답 없이 한 번에 맞춘 횟수가 5회 누적되면 해당 단어는 마스터한 것으로 간주하여 완료한 단어로 이동합니다.\n\n'
            '• 단어장: 현재 학습 중 단어 목록입니다. 단어 패키지 해제로만 새로운 단어를 추가할 수 있습니다.\n\n'
            '• 모르는 단어: 시험에서 틀린 단어들이 모이는 오답 노트입니다. 모르는 단어들만 모아 재시험을 볼 수 있습니다.\n\n'
            '• 단어 패키지: 단어장의 단어가 50개 이하일 때 패키지를 해제하여 새로운 단어를 추가할 수 있습니다.\n\n'
            '• 완료한 단어: 한 번에 맞춘 횟수가 5회 누적되어 학습을 마친 단어들이 보관됩니다. 필요시 이곳에서 단어장으로 다시 복구하여 재학습할 수 있습니다.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isFirstTime) {
                setState(() {
                  isTutorialCompleted = true;
                });
                saveUserData();
              }
            },
            child: const Text('확인', style: TextStyle(fontSize: 16)),
          )
        ],
      )
    );
  }

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
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => _showManualDialog(isFirstTime: false),
          child: const Text('설명서', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
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
              '* 단어장 시험에서 한 번에 맞춘 횟수가 5번인 단어는 완료한 단어로 자동 이동합니다.',
              style: TextStyle(color: Colors.brown, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allWords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${allWords[index].kr} : ${allWords[index].jp}'),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    onPressed: () => _restoreWord(index),
                    child: const Text('재학습', style: TextStyle(color: Colors.white)),
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

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<Word> _currentQuizData = [];
  List<Word> _currentSessionIncorrect = [];
  List<Word> _masteredThisSession = [];
  int _currentIndex = 0;
  bool _isFirstTry = true;
  bool _showError = false;
  bool _showCheckmark = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startQuizData();
    
    _fadeController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 200)
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
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
    if (_currentIndex >= _currentQuizData.length) return;
    
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
        
        if (_currentIndex < _currentQuizData.length) {
          _showCheckmark = true;
        }
      });

      if (_currentIndex < _currentQuizData.length) {
        _fadeController.forward(from: 0.0);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showCheckmark = false;
            });
          }
        });
      }
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
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
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
                          onChanged: (val) {
                            if (_currentIndex < _currentQuizData.length && val.trim() == _currentQuizData[_currentIndex].jp) {
                              _checkAnswer(val);
                            }
                          },
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
                if (_showCheckmark)
                  const Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 60),
                  ),
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