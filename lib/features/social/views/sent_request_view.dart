import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../provider/friend_request_provider.dart';
import '../widgets/animated_toast.dart';
import '../widgets/sent_request_card.dart';

class SentRequestView extends ConsumerWidget {
  const SentRequestView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentRequestsAsync = ref.watch(sentRequestsProvider);

    return Container(
      color: const Color(0x7FDFE1DC),
      child: sentRequestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text('보낸 요청이 없습니다.', style: AppTypography.b2),
            );
          }
          return ListView.builder(
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('데이터를 불러오는데 실패했습니다.')),
      ),
    );
  }
}
