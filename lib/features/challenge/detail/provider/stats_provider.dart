import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/stats_repository.dart';
import '../models/challenge_stats.dart';

part 'stats_provider.g.dart';

@riverpod
Future<ChallengeStats> challengeStats(Ref ref, int challengeId) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getChallengeStats(challengeId);
}
