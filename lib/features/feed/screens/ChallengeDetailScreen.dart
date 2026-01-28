import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ChallengeDetailPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ChallengeDetailPage extends StatelessWidget {
  const ChallengeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.black,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '챌린지 상세정보',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(
            height: 1,
            color: AppColors.gray4, //
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '토익 단어 매일 20개 외우기',
                    style: AppTypography.h3.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 25),

                  _buildInfoSection('챌린지 시작일', '0000년 00월 00일'),
                  _buildInfoSection('챌린지 마감일', '0000년 00월 00일 (D-000)'),
                  _buildInfoSection('인증 빈도', '매일'),
                  _buildInfoSection('챌린지 인증 방식', '사진 첨부 필수'),

                  Text(
                    '챌린지 태그',
                    style: AppTypography.b1.copyWith(color: AppColors.gray2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag('label'),
                      const SizedBox(width: 8),
                      _buildTag('label'),
                    ],
                  ),

                  const Divider(
                    height: 40,
                    thickness: 1,
                    color: AppColors.gray4, //
                  ),

                  Text(
                    '챌린지 설명',
                    style: AppTypography.b1.copyWith(color: AppColors.gray2),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '오늘의 단어 하나 공유하기\n하루에 한 번 인증 게시물 올리기',
                    style: AppTypography.b1.copyWith(color: AppColors.black),
                  ),

                  const Divider(
                    height: 40,
                    thickness: 1,
                    color: AppColors.gray4, //
                  ),

                  Text(
                    '방장',
                    style: AppTypography.b1.copyWith(color: AppColors.gray2),
                  ),
                  const SizedBox(height: 10),
                  _buildChallengeManager('김민수'),

                  const Divider(
                    height: 40,
                    thickness: 1,
                    color: AppColors.gray4, //
                  ),

                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icons/person_icon.svg',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '참여자 수',
                        style: AppTypography.b1.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '00명',
                    style: AppTypography.b1.copyWith(color: AppColors.black),
                  ),

                  const Divider(
                    height: 40,
                    thickness: 1,
                    color: AppColors.gray4, //
                  ),

                  Text(
                    '오늘의 인증자',
                    style: AppTypography.b1.copyWith(color: AppColors.gray2),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAttendee('승빈'),
                        _buildAttendee('김민수'),
                        _buildAttendee('김이박정민수'),
                        _buildAttendee('수'),
                        _buildAttendee('사용자이름'),
                        _buildAttendee('승빈'),
                        _buildAttendee('김민수'),
                        _buildAttendee('김이박정민수'),
                        _buildAttendee('수'),
                        _buildAttendee('사용자이름'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    height: 40,
                    thickness: 1,
                    color: AppColors.gray4, //
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 하단 고정 - 인증하기 버튼
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAble,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 8,
            ),
            child: Text(
              '챌린지 참여하기',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // 반복되는 정보 텍스트 위젯
  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.b1.copyWith(color: AppColors.gray2)),
          Text(
            content,
            style: AppTypography.b1.copyWith(color: AppColors.black),
          ),
        ],
      ),
    );
  }

  // 태그 위젯
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: AppTypography.b1.copyWith(color: AppColors.primaryAble),
      ),
    );
  }

  // 방장 위젯
  Widget _buildChallengeManager(String name) {
    return Row(
      children: [
        SvgPicture.asset('assets/images/icons/default_profile_icon.svg'),
        const SizedBox(width: 12),
        Text(name, style: AppTypography.b1.copyWith(color: AppColors.black)),
      ],
    );
  }

  // 오늘의 인증자 아이템 위젯
  Widget _buildAttendee(String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          SvgPicture.asset('assets/images/icons/default_profile_icon.svg'),
          const SizedBox(height: 5),
          Text(name, style: AppTypography.c1.copyWith(color: AppColors.black)),
        ],
      ),
    );
  }
}
