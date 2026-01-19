// 최초 작성자: 김채영

import 'package:flutter/material.dart';

class AppTypography {
  // Heading 1: 페이지 타이틀
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 24.0, // Size: 24px
    fontWeight: FontWeight.w700, // Weight: Bold(700)
    height: 1.41, // Line Height: 34px / 24px = 약 1.4
  );
  // Heading 2: 섹션 타이틀, 모달 제목
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    height: 1.4, // 28px / 20px
  );

  // Heading 3: 게시글 제목, 카드 제목
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.44, // 26px / 18px
  );

  // Body 1: 기본 본문, 입력창, 버튼
  static const TextStyle b1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16.0,
    fontWeight: FontWeight.w500, // 버튼용 Medium 추천
    height: 1.5, // 24px / 16px
  );

  // Body 2: 보조 본문, 상세 내용
  static const TextStyle b2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5, // 21px / 14px
  );

  // Body 3: 기본 본문 강조용
  static const TextStyle b3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5, // 24px / 16px
  );

  // Caption 1: 날짜, 에러 메시지
  static const TextStyle c1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.5, // 18px / 12px
  );

  // Caption 2: 하단 탭바 라벨
  static const TextStyle c2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
  );
}
