// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayTotalStatusHash() => r'b51b5f01e4941d5d5f4382e00fc586324187176d';

/// See also [todayTotalStatus].
@ProviderFor(todayTotalStatus)
final todayTotalStatusProvider = AutoDisposeProvider<ChallengeStatus>.internal(
  todayTotalStatus,
  name: r'todayTotalStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTotalStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTotalStatusRef = AutoDisposeProviderRef<ChallengeStatus>;
String _$challengeCalendarDataHash() =>
    r'f98f24f51387e5a39a38ec6c484831fdb14d30e0';

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

/// See also [challengeCalendarData].
@ProviderFor(challengeCalendarData)
const challengeCalendarDataProvider = ChallengeCalendarDataFamily();

/// See also [challengeCalendarData].
class ChallengeCalendarDataFamily
    extends Family<AsyncValue<ChallengeCalendarModel>> {
  /// See also [challengeCalendarData].
  const ChallengeCalendarDataFamily();

  /// See also [challengeCalendarData].
  ChallengeCalendarDataProvider call(int challengeId) {
    return ChallengeCalendarDataProvider(challengeId);
  }

  @override
  ChallengeCalendarDataProvider getProviderOverride(
    covariant ChallengeCalendarDataProvider provider,
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
  String? get name => r'challengeCalendarDataProvider';
}

/// See also [challengeCalendarData].
class ChallengeCalendarDataProvider
    extends AutoDisposeFutureProvider<ChallengeCalendarModel> {
  /// See also [challengeCalendarData].
  ChallengeCalendarDataProvider(int challengeId)
    : this._internal(
        (ref) =>
            challengeCalendarData(ref as ChallengeCalendarDataRef, challengeId),
        from: challengeCalendarDataProvider,
        name: r'challengeCalendarDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$challengeCalendarDataHash,
        dependencies: ChallengeCalendarDataFamily._dependencies,
        allTransitiveDependencies:
            ChallengeCalendarDataFamily._allTransitiveDependencies,
        challengeId: challengeId,
      );

  ChallengeCalendarDataProvider._internal(
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
    FutureOr<ChallengeCalendarModel> Function(ChallengeCalendarDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChallengeCalendarDataProvider._internal(
        (ref) => create(ref as ChallengeCalendarDataRef),
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
  AutoDisposeFutureProviderElement<ChallengeCalendarModel> createElement() {
    return _ChallengeCalendarDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeCalendarDataProvider &&
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
mixin ChallengeCalendarDataRef
    on AutoDisposeFutureProviderRef<ChallengeCalendarModel> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _ChallengeCalendarDataProviderElement
    extends AutoDisposeFutureProviderElement<ChallengeCalendarModel>
    with ChallengeCalendarDataRef {
  _ChallengeCalendarDataProviderElement(super.provider);

  @override
  int get challengeId => (origin as ChallengeCalendarDataProvider).challengeId;
}

String _$challengePostsHash() => r'08fedb7bb5a647c8fc3744997c2179902fb31fcd';

/// See also [challengePosts].
@ProviderFor(challengePosts)
const challengePostsProvider = ChallengePostsFamily();

/// See also [challengePosts].
class ChallengePostsFamily
    extends Family<AsyncValue<List<CertificationPostModel>>> {
  /// See also [challengePosts].
  const ChallengePostsFamily();

  /// See also [challengePosts].
  ChallengePostsProvider call({
    required int challengeId,
    required int year,
    required int month,
  }) {
    return ChallengePostsProvider(
      challengeId: challengeId,
      year: year,
      month: month,
    );
  }

  @override
  ChallengePostsProvider getProviderOverride(
    covariant ChallengePostsProvider provider,
  ) {
    return call(
      challengeId: provider.challengeId,
      year: provider.year,
      month: provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'challengePostsProvider';
}

/// See also [challengePosts].
class ChallengePostsProvider
    extends AutoDisposeFutureProvider<List<CertificationPostModel>> {
  /// See also [challengePosts].
  ChallengePostsProvider({
    required int challengeId,
    required int year,
    required int month,
  }) : this._internal(
         (ref) => challengePosts(
           ref as ChallengePostsRef,
           challengeId: challengeId,
           year: year,
           month: month,
         ),
         from: challengePostsProvider,
         name: r'challengePostsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$challengePostsHash,
         dependencies: ChallengePostsFamily._dependencies,
         allTransitiveDependencies:
             ChallengePostsFamily._allTransitiveDependencies,
         challengeId: challengeId,
         year: year,
         month: month,
       );

  ChallengePostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.challengeId,
    required this.year,
    required this.month,
  }) : super.internal();

  final int challengeId;
  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<List<CertificationPostModel>> Function(ChallengePostsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChallengePostsProvider._internal(
        (ref) => create(ref as ChallengePostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        challengeId: challengeId,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CertificationPostModel>>
  createElement() {
    return _ChallengePostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengePostsProvider &&
        other.challengeId == challengeId &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChallengePostsRef
    on AutoDisposeFutureProviderRef<List<CertificationPostModel>> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _ChallengePostsProviderElement
    extends AutoDisposeFutureProviderElement<List<CertificationPostModel>>
    with ChallengePostsRef {
  _ChallengePostsProviderElement(super.provider);

  @override
  int get challengeId => (origin as ChallengePostsProvider).challengeId;
  @override
  int get year => (origin as ChallengePostsProvider).year;
  @override
  int get month => (origin as ChallengePostsProvider).month;
}

String _$challengeHomeNotifierHash() =>
    r'ce230999a0c31c320d048d283d07a5fd954c1df3';

/// See also [ChallengeHomeNotifier].
@ProviderFor(ChallengeHomeNotifier)
final challengeHomeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ChallengeHomeNotifier,
      ChallengeMainModel
    >.internal(
      ChallengeHomeNotifier.new,
      name: r'challengeHomeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$challengeHomeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChallengeHomeNotifier = AutoDisposeAsyncNotifier<ChallengeMainModel>;
String _$challengeCreateNotifierHash() =>
    r'cbc4cd944ef88513ff25539f16dbe448af4446e6';

/// See also [ChallengeCreateNotifier].
@ProviderFor(ChallengeCreateNotifier)
final challengeCreateNotifierProvider =
    AutoDisposeNotifierProvider<
      ChallengeCreateNotifier,
      AsyncValue<ChallengeCreateResponse?>
    >.internal(
      ChallengeCreateNotifier.new,
      name: r'challengeCreateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$challengeCreateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChallengeCreateNotifier =
    AutoDisposeNotifier<AsyncValue<ChallengeCreateResponse?>>;
String _$articleCreateNotifierHash() =>
    r'ef629d79463f50634d6335ec21454552edcf7ed9';

/// See also [ArticleCreateNotifier].
@ProviderFor(ArticleCreateNotifier)
final articleCreateNotifierProvider =
    AutoDisposeNotifierProvider<
      ArticleCreateNotifier,
      AsyncValue<CertificationPostModel?>
    >.internal(
      ArticleCreateNotifier.new,
      name: r'articleCreateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleCreateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleCreateNotifier =
    AutoDisposeNotifier<AsyncValue<CertificationPostModel?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
