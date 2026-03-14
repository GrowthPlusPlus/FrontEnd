// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

import 'package:haenaem/shared/widgets/user_profile_circle.dart';
import '../models/friend_request_card.dart';

class SentRequestCard extends StatelessWidget {
  final FriendRequestCard request;
  final VoidCallback onCancel;

  const SentRequestCard({
    super.key,
    required this.request,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserProfileCircle(
                    imageUrl: request.user.profileUrl,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.user.nickname, style: AppTypography.h3),
                      Text(
                        DateFormat('yyyy년 MM월 dd일').format(request.requestDate),
                        style: AppTypography.c2.copyWith(
                          color: AppColors.gray3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildBadge('대기 중'),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0x7FDFE1DC),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '요청 취소',
                style: AppTypography.b1.copyWith(
                  color: AppColors.gray2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF444444), fontSize: 12),
      ),
    );
  }
}
