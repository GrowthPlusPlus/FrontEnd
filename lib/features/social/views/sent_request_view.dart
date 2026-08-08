// 최초 작성자: 정승빈
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import '../provider/friend_request_provider.dart';
import '../../../shared/widgets/animated_toast.dart';
import '../widgets/sent_request_card.dart';

class SentRequestView extends ConsumerWidget {
  const SentRequestView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final sentRequestsAsync = ref.watch(sentRequestsProvider);

    return Container(
      color: appColors.gray5,
      child: sentRequestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text('보낸 요청이 없습니다.', style: AppTypography.b2),
            );
          }
          return RefreshIndicator(
            color: appColors.primaryAble,
            onRefresh: () async {
              // 새로고침 시 Provider의 Future를 다시 호출하여 최신 데이터 가져오기
              return await ref.refresh(sentRequestsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return SentRequestCard(
                  request: req,
                  onCancel: () async {
                    try {
                      await ref
                          .read(sentRequestsProvider.notifier)
                          .cancelRequest(req.requestId);
                      if (context.mounted) {
                        displayToast(context, '친구 신청을 취소했습니다.');
                      }
                    } catch (e) {
                      if (context.mounted) displayToast(context, '취소에 실패했습니다.');
                    }
                  },
                );
              },
              // 항상 스크롤 가능하도록 설정 (요청이 1개 이하일 때도 당겨서 새로고침 가능)
              physics: const AlwaysScrollableScrollPhysics(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('데이터를 불러오는데 실패했습니다.')),
      ),
    );
  }
}
