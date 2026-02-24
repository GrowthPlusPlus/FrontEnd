// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$topRankingsHash() => r'3966ecf96a590eeac7cb72fe4b8bb4eaeecfbd10';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 전체 랭킹 리스트만 따로 관리하는 파생 Provider
/// UI에서 data.topRankings에 직접 접근하는 대신 사용하면 편리합니다.
///
/// Copied from [topRankings].
@ProviderFor(topRankings)
const topRankingsProvider = TopRankingsFamily();

/// 전체 랭킹 리스트만 따로 관리하는 파생 Provider
/// UI에서 data.topRankings에 직접 접근하는 대신 사용하면 편리합니다.
///
/// Copied from [topRankings].
class TopRankingsFamily extends Family<AsyncValue<List<RankingUser>>> {
  /// 전체 랭킹 리스트만 따로 관리하는 파생 Provider
  /// UI에서 data.topRankings에 직접 접근하는 대신 사용하면 편리합니다.
  ///
  /// Copied from [topRankings].
  const TopRankingsFamily();

  /// 전체 랭킹 리스트만 따로 관리하는 파생 Provider
  /// UI에서 data.topRankings에 직접 접근하는 대신 사용하면 편리합니다.
  ///
  /// Copied from [topRankings].
  TopRankingsProvider call(int challengeId) {
    return TopRankingsProvider(challengeId);
  }

  @override
  TopRankingsProvider getProviderOverride(
    covariant TopRankingsProvider provider,
  ) {
    return call(provider.challengeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'topRankingsProvider';
}

/// 전체 랭킹 리스트만 따로 관리하는 파생 Provider
/// UI에서 data.topRankings에 직접 접근하는 대신 사용하면 편리합니다.
///
/// Copied from [topRankings].
class TopRankingsProvider extends AutoDisposeFutureProvider<List<RankingUser>> {
  /// 전체 랭킹 리스트만 따로 관리하는 파생 Provider
  /// UI에서 data.topRankings에 직접 접근하는 대신 사용하면 편리합니다.
  ///
  /// Copied from [topRankings].
  TopRankingsProvider(int challengeId)
    : this._internal(
        (ref) => topRankings(ref as TopRankingsRef, challengeId),
        from: topRankingsProvider,
        name: r'topRankingsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$topRankingsHash,
        dependencies: TopRankingsFamily._dependencies,
        allTransitiveDependencies: TopRankingsFamily._allTransitiveDependencies,
        challengeId: challengeId,
      );

  TopRankingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.challengeId,
  }) : super.internal();

  final int challengeId;

  @override
  Override overrideWith(
    FutureOr<List<RankingUser>> Function(TopRankingsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TopRankingsProvider._internal(
        (ref) => create(ref as TopRankingsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        challengeId: challengeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RankingUser>> createElement() {
    return _TopRankingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopRankingsProvider && other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TopRankingsRef on AutoDisposeFutureProviderRef<List<RankingUser>> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _TopRankingsProviderElement
    extends AutoDisposeFutureProviderElement<List<RankingUser>>
    with TopRankingsRef {
  _TopRankingsProviderElement(super.provider);

  @override
  int get challengeId => (origin as TopRankingsProvider).challengeId;
}

String _$myRankingHash() => r'82548d46ddd09778fb6eab54dcbf3947cf736890';

/// 내 랭킹 정보만 따로 관리하는 파생 Provider
///
/// Copied from [myRanking].
@ProviderFor(myRanking)
const myRankingProvider = MyRankingFamily();

/// 내 랭킹 정보만 따로 관리하는 파생 Provider
///
/// Copied from [myRanking].
class MyRankingFamily extends Family<AsyncValue<RankingUser>> {
  /// 내 랭킹 정보만 따로 관리하는 파생 Provider
  ///
  /// Copied from [myRanking].
  const MyRankingFamily();

  /// 내 랭킹 정보만 따로 관리하는 파생 Provider
  ///
  /// Copied from [myRanking].
  MyRankingProvider call(int challengeId) {
    return MyRankingProvider(challengeId);
  }

  @override
  MyRankingProvider getProviderOverride(covariant MyRankingProvider provider) {
    return call(provider.challengeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myRankingProvider';
}

/// 내 랭킹 정보만 따로 관리하는 파생 Provider
///
/// Copied from [myRanking].
class MyRankingProvider extends AutoDisposeFutureProvider<RankingUser> {
  /// 내 랭킹 정보만 따로 관리하는 파생 Provider
  ///
  /// Copied from [myRanking].
  MyRankingProvider(int challengeId)
    : this._internal(
        (ref) => myRanking(ref as MyRankingRef, challengeId),
        from: myRankingProvider,
        name: r'myRankingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myRankingHash,
        dependencies: MyRankingFamily._dependencies,
        allTransitiveDependencies: MyRankingFamily._allTransitiveDependencies,
        challengeId: challengeId,
      );

  MyRankingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.challengeId,
  }) : super.internal();

  final int challengeId;

  @override
  Override overrideWith(
    FutureOr<RankingUser> Function(MyRankingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyRankingProvider._internal(
        (ref) => create(ref as MyRankingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        challengeId: challengeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RankingUser> createElement() {
    return _MyRankingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRankingProvider && other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyRankingRef on AutoDisposeFutureProviderRef<RankingUser> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _MyRankingProviderElement
    extends AutoDisposeFutureProviderElement<RankingUser>
    with MyRankingRef {
  _MyRankingProviderElement(super.provider);

  @override
  int get challengeId => (origin as MyRankingProvider).challengeId;
}

String _$isMyRankingInTopThreeHash() =>
    r'df799b9ea8176f77e3163a0ca2cc25ac1fc7cd00';

/// 상위 3명(TOP 3) 유지만 따로 체크하는 상태 Provider
///
/// Copied from [isMyRankingInTopThree].
@ProviderFor(isMyRankingInTopThree)
const isMyRankingInTopThreeProvider = IsMyRankingInTopThreeFamily();

/// 상위 3명(TOP 3) 유지만 따로 체크하는 상태 Provider
///
/// Copied from [isMyRankingInTopThree].
class IsMyRankingInTopThreeFamily extends Family<bool> {
  /// 상위 3명(TOP 3) 유지만 따로 체크하는 상태 Provider
  ///
  /// Copied from [isMyRankingInTopThree].
  const IsMyRankingInTopThreeFamily();

  /// 상위 3명(TOP 3) 유지만 따로 체크하는 상태 Provider
  ///
  /// Copied from [isMyRankingInTopThree].
  IsMyRankingInTopThreeProvider call(int challengeId) {
    return IsMyRankingInTopThreeProvider(challengeId);
  }

  @override
  IsMyRankingInTopThreeProvider getProviderOverride(
    covariant IsMyRankingInTopThreeProvider provider,
  ) {
    return call(provider.challengeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isMyRankingInTopThreeProvider';
}

/// 상위 3명(TOP 3) 유지만 따로 체크하는 상태 Provider
///
/// Copied from [isMyRankingInTopThree].
class IsMyRankingInTopThreeProvider extends AutoDisposeProvider<bool> {
  /// 상위 3명(TOP 3) 유지만 따로 체크하는 상태 Provider
  ///
  /// Copied from [isMyRankingInTopThree].
  IsMyRankingInTopThreeProvider(int challengeId)
    : this._internal(
        (ref) =>
            isMyRankingInTopThree(ref as IsMyRankingInTopThreeRef, challengeId),
        from: isMyRankingInTopThreeProvider,
        name: r'isMyRankingInTopThreeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isMyRankingInTopThreeHash,
        dependencies: IsMyRankingInTopThreeFamily._dependencies,
        allTransitiveDependencies:
            IsMyRankingInTopThreeFamily._allTransitiveDependencies,
        challengeId: challengeId,
      );

  IsMyRankingInTopThreeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.challengeId,
  }) : super.internal();

  final int challengeId;

  @override
  Override overrideWith(
    bool Function(IsMyRankingInTopThreeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsMyRankingInTopThreeProvider._internal(
        (ref) => create(ref as IsMyRankingInTopThreeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        challengeId: challengeId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsMyRankingInTopThreeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsMyRankingInTopThreeProvider &&
        other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsMyRankingInTopThreeRef on AutoDisposeProviderRef<bool> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _IsMyRankingInTopThreeProviderElement
    extends AutoDisposeProviderElement<bool>
    with IsMyRankingInTopThreeRef {
  _IsMyRankingInTopThreeProviderElement(super.provider);

  @override
  int get challengeId => (origin as IsMyRankingInTopThreeProvider).challengeId;
}

String _$challengeRankingNotifierHash() =>
    r'37ba8169300dac2d7c8a5db193edc5be9d265b75';

abstract class _$ChallengeRankingNotifier
    extends BuildlessAutoDisposeAsyncNotifier<RankingResponse> {
  late final int challengeId;

  FutureOr<RankingResponse> build(int challengeId);
}

/// 특정 챌린지의 랭킹 데이터를 관리하는 Notifier
///
/// Copied from [ChallengeRankingNotifier].
@ProviderFor(ChallengeRankingNotifier)
const challengeRankingNotifierProvider = ChallengeRankingNotifierFamily();

/// 특정 챌린지의 랭킹 데이터를 관리하는 Notifier
///
/// Copied from [ChallengeRankingNotifier].
class ChallengeRankingNotifierFamily
    extends Family<AsyncValue<RankingResponse>> {
  /// 특정 챌린지의 랭킹 데이터를 관리하는 Notifier
  ///
  /// Copied from [ChallengeRankingNotifier].
  const ChallengeRankingNotifierFamily();

  /// 특정 챌린지의 랭킹 데이터를 관리하는 Notifier
  ///
  /// Copied from [ChallengeRankingNotifier].
  ChallengeRankingNotifierProvider call(int challengeId) {
    return ChallengeRankingNotifierProvider(challengeId);
  }

  @override
  ChallengeRankingNotifierProvider getProviderOverride(
    covariant ChallengeRankingNotifierProvider provider,
  ) {
    return call(provider.challengeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'challengeRankingNotifierProvider';
}

/// 특정 챌린지의 랭킹 데이터를 관리하는 Notifier
///
/// Copied from [ChallengeRankingNotifier].
class ChallengeRankingNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ChallengeRankingNotifier,
          RankingResponse
        > {
  /// 특정 챌린지의 랭킹 데이터를 관리하는 Notifier
  ///
  /// Copied from [ChallengeRankingNotifier].
  ChallengeRankingNotifierProvider(int challengeId)
    : this._internal(
        () => ChallengeRankingNotifier()..challengeId = challengeId,
        from: challengeRankingNotifierProvider,
        name: r'challengeRankingNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$challengeRankingNotifierHash,
        dependencies: ChallengeRankingNotifierFamily._dependencies,
        allTransitiveDependencies:
            ChallengeRankingNotifierFamily._allTransitiveDependencies,
        challengeId: challengeId,
      );

  ChallengeRankingNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.challengeId,
  }) : super.internal();

  final int challengeId;

  @override
  FutureOr<RankingResponse> runNotifierBuild(
    covariant ChallengeRankingNotifier notifier,
  ) {
    return notifier.build(challengeId);
  }

  @override
  Override overrideWith(ChallengeRankingNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChallengeRankingNotifierProvider._internal(
        () => create()..challengeId = challengeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        challengeId: challengeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ChallengeRankingNotifier,
    RankingResponse
  >
  createElement() {
    return _ChallengeRankingNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeRankingNotifierProvider &&
        other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChallengeRankingNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<RankingResponse> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _ChallengeRankingNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ChallengeRankingNotifier,
          RankingResponse
        >
    with ChallengeRankingNotifierRef {
  _ChallengeRankingNotifierProviderElement(super.provider);

  @override
  int get challengeId =>
      (origin as ChallengeRankingNotifierProvider).challengeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
