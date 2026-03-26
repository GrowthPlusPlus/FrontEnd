import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/shared/models/challenge_detail.dart';
import 'package:haenaem/features/challenge/detail/data/challenge_detail_repository.dart';

part 'challenge_detail_provider.g.dart';

// 최초 작성자 : 강선욱
// 챌린지 상세 정보 provider
@riverpod
Future<ChallengeDetail> challengeDetail(
  Ref ref, {
  required int challengeId,
}) async {
  final repository = ref.watch(challengeDetailRepositoryProvider);
  return repository.getChallengeDetail(challengeId);
}
