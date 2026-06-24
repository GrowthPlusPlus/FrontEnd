// 최초 작성자: 정승빈

import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';
import '../widgets/report_reason_tile.dart';
import 'report_success_screen.dart';
import 'package:haenaem/features/report/provider/report_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final ReportTargetType targetType;
  final int targetId;

  const ReportScreen({
    super.key,
    required this.targetType,
    required this.targetId,
  });
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int? _selectedReasonIndex;
  final TextEditingController _otherReasonController = TextEditingController();

  // 백엔드 API 명세에 맞게 keys 값을 꼭 수정해주세요!
  final List<Map<String, String>> _reasons = [
    {'key': 'SPAM', 'title': '영리목적/홍보성', 'desc': '상업적 광고, 도배성 게시글, 링크 유도 등'},
    {
      'key': 'ABUSE',
      'title': '욕설/비하 발언',
      'desc': '특정 개인이나 집단에 대한 혐오, 비하, 욕설 포함',
    },
    {
      'key': 'INAPPROPRIATE',
      'title': '부적절한 콘텐츠',
      'desc': '음란물, 폭력적 내용, 불법 정보 포함',
    },
    {'key': 'PRIVACY', 'title': '개인정보 노출', 'desc': '타인의 연락처, 주소 등 민감한 정보 공유'},
    {
      'key': 'IMPERSONATION',
      'title': '명의 도용/사칭',
      'desc': '타인을 사칭하거나 저작권을 침해하는 이미지 사용',
    },
    {'key': 'ETC', 'title': '기타 (직접 입력)', 'desc': '위 항목에 해당하지 않는 구체적인 사유'},
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReasonIndex == null) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final selectedKey = _reasons[_selectedReasonIndex!]['key']!;
    final detailReason = _selectedReasonIndex == 5
        ? _otherReasonController.text
        : '';

    // 바뀐 부분: 모델 객체 생성 없이 파라미터로 바로 전달
    final success = await ref
        .read(reportControllerProvider.notifier)
        .submitReport(
          targetType: widget.targetType,
          targetId: widget.targetId,
          reportReason: selectedKey,
          detailReason: detailReason,
        );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ReportSuccessScreen()),
      );
    } else if (mounted) {
      displayToast(context, '신고 접수에 실패했습니다. 다시 시도해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 항목이 하나라도 선택되었는지 여부로 하단 버튼 활성화 상태 결정
    final bool isButtonActive = _selectedReasonIndex != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('신고하기', style: AppTypography.h3),
      ),
      body: Column(
        children: [
          // 상단 안내 문구
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              '더 깨끗한 \'해냄\'을 위해 부적절한 콘텐츠를 알려주세요.\n신고하신 내용은 운영 정책에 따라 검토 후 조치됩니다.',
              textAlign: TextAlign.center,
              style: AppTypography.b2.copyWith(color: AppColors.gray2),
            ),
          ),

          // 신고 사유 리스트
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _reasons.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final isSelected = _selectedReasonIndex == index;
                final isOtherOption = index == _reasons.length - 1;

                return ReportReasonTile(
                  title: _reasons[index]['title']!,
                  subtitle: _reasons[index]['desc']!,
                  isSelected: isSelected,
                  isOtherOption: isOtherOption,
                  textController: _otherReasonController,
                  onTap: () {
                    setState(() {
                      _selectedReasonIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 하단 고정 버튼
      bottomNavigationBar: BottomActionButton(
        text: '신고하기',
        backgroundColor: isButtonActive
            ? AppColors.primaryAble
            : AppColors.disable,
        onPressed: isButtonActive ? _submitReport : () {},
      ),
    );
  }
}
