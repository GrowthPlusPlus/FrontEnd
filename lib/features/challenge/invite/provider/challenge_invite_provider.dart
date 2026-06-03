// 최초 작성자: 정승빈
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/challenge_invite_repository.dart';
import '../models/invite_response.dart';

part 'challenge_invite_provider.g.dart';

/// 챌린지 초대 정보 Provider
/// - ChallengeInviteContent에서 ref.watch(challengeInviteInfoProvider(challengeId))로 사용
@riverpod
Future<ChallengeInviteResponse> challengeInvite(
  Ref ref,
  int challengeId,
) async {
  final repository = ref.watch(challengeInviteRepositoryProvider);
  return repository.getChallengeInviteInfo(challengeId);
}
