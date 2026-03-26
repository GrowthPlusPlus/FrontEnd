import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/features/home/data/home_repository.dart';
import 'package:haenaem/features/home/models/home_response.dart';

part 'home_provider.g.dart';

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  FutureOr<HomeResponse> build() async {
    return ref
        .watch(homeRepositoryProvider)
        .getHomeData(_getFormattedDate(DateTime.now()));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(homeRepositoryProvider)
          .getHomeData(_getFormattedDate(DateTime.now())),
    );
  }

  String _getFormattedDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }
}
