import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/calendar_post.dart';
import '../data/post_repository.dart';

part 'post_provider.g.dart';

// 최초 작성자 : 강선욱
// 내현황 탭 달력, 인증글 리스트 데이터 불러오기
@riverpod
Future<List<CalendarPost>> monthlyChallengePosts(
  Ref ref, {
  required int challengeId,
  required int year,
  required int month,
}) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getChallengePosts(
    challengeId: challengeId,
    year: year,
    month: month,
  );
}
