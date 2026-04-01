// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeDetailHash() => r'74cf37d6cd49e4aab0f276a03f7471edd65c1c0b';

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

/// See also [challengeDetail].
@ProviderFor(challengeDetail)
const challengeDetailProvider = ChallengeDetailFamily();

/// See also [challengeDetail].
class ChallengeDetailFamily extends Family<AsyncValue<ChallengeDetailModel>> {
  /// See also [challengeDetail].
  const ChallengeDetailFamily();

  /// See also [challengeDetail].
  ChallengeDetailProvider call({required int challengeId}) {
    return ChallengeDetailProvider(challengeId: challengeId);
  }

  @override
  ChallengeDetailProvider getProviderOverride(
    covariant ChallengeDetailProvider provider,
  ) {
    return call(challengeId: provider.challengeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'challengeDetailProvider';
}

/// See also [challengeDetail].
class ChallengeDetailProvider
    extends AutoDisposeFutureProvider<ChallengeDetailModel> {
  /// See also [challengeDetail].
  ChallengeDetailProvider({required int challengeId})
    : this._internal(
        (ref) => challengeDetail(
          ref as ChallengeDetailRef,
          challengeId: challengeId,
        ),
        from: challengeDetailProvider,
        name: r'challengeDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$challengeDetailHash,
        dependencies: ChallengeDetailFamily._dependencies,
        allTransitiveDependencies:
            ChallengeDetailFamily._allTransitiveDependencies,
        challengeId: challengeId,
      );

  ChallengeDetailProvider._internal(
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
    FutureOr<ChallengeDetailModel> Function(ChallengeDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChallengeDetailProvider._internal(
        (ref) => create(ref as ChallengeDetailRef),
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
  AutoDisposeFutureProviderElement<ChallengeDetailModel> createElement() {
    return _ChallengeDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeDetailProvider && other.challengeId == challengeId;
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
mixin ChallengeDetailRef on AutoDisposeFutureProviderRef<ChallengeDetailModel> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _ChallengeDetailProviderElement
    extends AutoDisposeFutureProviderElement<ChallengeDetailModel>
    with ChallengeDetailRef {
  _ChallengeDetailProviderElement(super.provider);

  @override
  int get challengeId => (origin as ChallengeDetailProvider).challengeId;
}

String _$todayTotalStatusHash() => r'538019eb21a25b4148687cc999fca4c729a86b93';

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
String _$allTagsHash() => r'509a8857edbc465e553a55ab145a6a56fd3ac1f8';

/// See also [allTags].
@ProviderFor(allTags)
final allTagsProvider =
    AutoDisposeFutureProvider<List<ChallengeTagModel>>.internal(
      allTags,
      name: r'allTagsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allTagsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTagsRef = AutoDisposeFutureProviderRef<List<ChallengeTagModel>>;
String _$challengeCalendarDataHash() =>
    r'f98f24f51387e5a39a38ec6c484831fdb14d30e0';

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

String _$challengePostsHash() => r'ab79af0eb7249924a57b379a02a986c1a8e97bab';

/// See also [challengePosts].
@ProviderFor(challengePosts)
const challengePostsProvider = ChallengePostsFamily();

/// See also [challengePosts].
class ChallengePostsFamily extends Family<AsyncValue<List<Post>>> {
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
class ChallengePostsProvider extends AutoDisposeFutureProvider<List<Post>> {
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
    FutureOr<List<Post>> Function(ChallengePostsRef provider) create,
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
  AutoDisposeFutureProviderElement<List<Post>> createElement() {
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
mixin ChallengePostsRef on AutoDisposeFutureProviderRef<List<Post>> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _ChallengePostsProviderElement
    extends AutoDisposeFutureProviderElement<List<Post>>
    with ChallengePostsRef {
  _ChallengePostsProviderElement(super.provider);

  @override
  int get challengeId => (origin as ChallengePostsProvider).challengeId;
  @override
  int get year => (origin as ChallengePostsProvider).year;
  @override
  int get month => (origin as ChallengePostsProvider).month;
}

String _$challengeCalendarPhotosHash() =>
    r'132312c2d59424752d6cc544a272c21ef578c4d3';

/// See also [challengeCalendarPhotos].
@ProviderFor(challengeCalendarPhotos)
const challengeCalendarPhotosProvider = ChallengeCalendarPhotosFamily();

/// See also [challengeCalendarPhotos].
class ChallengeCalendarPhotosFamily
    extends Family<AsyncValue<List<ChallengeCalendarPhoto>>> {
  /// See also [challengeCalendarPhotos].
  const ChallengeCalendarPhotosFamily();

  /// See also [challengeCalendarPhotos].
  ChallengeCalendarPhotosProvider call({
    required int challengeId,
    required int year,
    required int month,
  }) {
    return ChallengeCalendarPhotosProvider(
      challengeId: challengeId,
      year: year,
      month: month,
    );
  }

  @override
  ChallengeCalendarPhotosProvider getProviderOverride(
    covariant ChallengeCalendarPhotosProvider provider,
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
  String? get name => r'challengeCalendarPhotosProvider';
}

/// See also [challengeCalendarPhotos].
class ChallengeCalendarPhotosProvider
    extends AutoDisposeFutureProvider<List<ChallengeCalendarPhoto>> {
  /// See also [challengeCalendarPhotos].
  ChallengeCalendarPhotosProvider({
    required int challengeId,
    required int year,
    required int month,
  }) : this._internal(
         (ref) => challengeCalendarPhotos(
           ref as ChallengeCalendarPhotosRef,
           challengeId: challengeId,
           year: year,
           month: month,
         ),
         from: challengeCalendarPhotosProvider,
         name: r'challengeCalendarPhotosProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$challengeCalendarPhotosHash,
         dependencies: ChallengeCalendarPhotosFamily._dependencies,
         allTransitiveDependencies:
             ChallengeCalendarPhotosFamily._allTransitiveDependencies,
         challengeId: challengeId,
         year: year,
         month: month,
       );

  ChallengeCalendarPhotosProvider._internal(
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
    FutureOr<List<ChallengeCalendarPhoto>> Function(
      ChallengeCalendarPhotosRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChallengeCalendarPhotosProvider._internal(
        (ref) => create(ref as ChallengeCalendarPhotosRef),
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
  AutoDisposeFutureProviderElement<List<ChallengeCalendarPhoto>>
  createElement() {
    return _ChallengeCalendarPhotosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeCalendarPhotosProvider &&
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
mixin ChallengeCalendarPhotosRef
    on AutoDisposeFutureProviderRef<List<ChallengeCalendarPhoto>> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _ChallengeCalendarPhotosProviderElement
    extends AutoDisposeFutureProviderElement<List<ChallengeCalendarPhoto>>
    with ChallengeCalendarPhotosRef {
  _ChallengeCalendarPhotosProviderElement(super.provider);

  @override
  int get challengeId =>
      (origin as ChallengeCalendarPhotosProvider).challengeId;
  @override
  int get year => (origin as ChallengeCalendarPhotosProvider).year;
  @override
  int get month => (origin as ChallengeCalendarPhotosProvider).month;
}

String _$articleDetailHash() => r'42e7dfa2cfb3dbbb4b9ef61f740651aa6ecd5e67';

/// See also [articleDetail].
@ProviderFor(articleDetail)
const articleDetailProvider = ArticleDetailFamily();

/// See also [articleDetail].
class ArticleDetailFamily extends Family<AsyncValue<CertificationPostModel>> {
  /// See also [articleDetail].
  const ArticleDetailFamily();

  /// See also [articleDetail].
  ArticleDetailProvider call({required int postId}) {
    return ArticleDetailProvider(postId: postId);
  }

  @override
  ArticleDetailProvider getProviderOverride(
    covariant ArticleDetailProvider provider,
  ) {
    return call(postId: provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articleDetailProvider';
}

/// See also [articleDetail].
class ArticleDetailProvider
    extends AutoDisposeFutureProvider<CertificationPostModel> {
  /// See also [articleDetail].
  ArticleDetailProvider({required int postId})
    : this._internal(
        (ref) => articleDetail(ref as ArticleDetailRef, postId: postId),
        from: articleDetailProvider,
        name: r'articleDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleDetailHash,
        dependencies: ArticleDetailFamily._dependencies,
        allTransitiveDependencies:
            ArticleDetailFamily._allTransitiveDependencies,
        postId: postId,
      );

  ArticleDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final int postId;

  @override
  Override overrideWith(
    FutureOr<CertificationPostModel> Function(ArticleDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArticleDetailProvider._internal(
        (ref) => create(ref as ArticleDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CertificationPostModel> createElement() {
    return _ArticleDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleDetailProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticleDetailRef on AutoDisposeFutureProviderRef<CertificationPostModel> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _ArticleDetailProviderElement
    extends AutoDisposeFutureProviderElement<CertificationPostModel>
    with ArticleDetailRef {
  _ArticleDetailProviderElement(super.provider);

  @override
  int get postId => (origin as ArticleDetailProvider).postId;
}

String _$articleCommentsHash() => r'00b8c1f43a3b172a21fe298e17ea96bbccb54bba';

/// See also [articleComments].
@ProviderFor(articleComments)
const articleCommentsProvider = ArticleCommentsFamily();

/// See also [articleComments].
class ArticleCommentsFamily extends Family<AsyncValue<List<ChallengeComment>>> {
  /// See also [articleComments].
  const ArticleCommentsFamily();

  /// See also [articleComments].
  ArticleCommentsProvider call({required int postId, int page = 0}) {
    return ArticleCommentsProvider(postId: postId, page: page);
  }

  @override
  ArticleCommentsProvider getProviderOverride(
    covariant ArticleCommentsProvider provider,
  ) {
    return call(postId: provider.postId, page: provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'articleCommentsProvider';
}

/// See also [articleComments].
class ArticleCommentsProvider
    extends AutoDisposeFutureProvider<List<ChallengeComment>> {
  /// See also [articleComments].
  ArticleCommentsProvider({required int postId, int page = 0})
    : this._internal(
        (ref) => articleComments(
          ref as ArticleCommentsRef,
          postId: postId,
          page: page,
        ),
        from: articleCommentsProvider,
        name: r'articleCommentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleCommentsHash,
        dependencies: ArticleCommentsFamily._dependencies,
        allTransitiveDependencies:
            ArticleCommentsFamily._allTransitiveDependencies,
        postId: postId,
        page: page,
      );

  ArticleCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
    required this.page,
  }) : super.internal();

  final int postId;
  final int page;

  @override
  Override overrideWith(
    FutureOr<List<ChallengeComment>> Function(ArticleCommentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArticleCommentsProvider._internal(
        (ref) => create(ref as ArticleCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChallengeComment>> createElement() {
    return _ArticleCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleCommentsProvider &&
        other.postId == postId &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArticleCommentsRef
    on AutoDisposeFutureProviderRef<List<ChallengeComment>> {
  /// The parameter `postId` of this provider.
  int get postId;

  /// The parameter `page` of this provider.
  int get page;
}

class _ArticleCommentsProviderElement
    extends AutoDisposeFutureProviderElement<List<ChallengeComment>>
    with ArticleCommentsRef {
  _ArticleCommentsProviderElement(super.provider);

  @override
  int get postId => (origin as ArticleCommentsProvider).postId;
  @override
  int get page => (origin as ArticleCommentsProvider).page;
}

String _$myInProgressChallengesHash() =>
    r'4f53f796e087c3f28343d446396e079ac6ab81dc';

/// See also [myInProgressChallenges].
@ProviderFor(myInProgressChallenges)
const myInProgressChallengesProvider = MyInProgressChallengesFamily();

/// See also [myInProgressChallenges].
class MyInProgressChallengesFamily
    extends Family<AsyncValue<List<ChallengeInProgressModel>>> {
  /// See also [myInProgressChallenges].
  const MyInProgressChallengesFamily();

  /// See also [myInProgressChallenges].
  MyInProgressChallengesProvider call({bool onlyTwo = false}) {
    return MyInProgressChallengesProvider(onlyTwo: onlyTwo);
  }

  @override
  MyInProgressChallengesProvider getProviderOverride(
    covariant MyInProgressChallengesProvider provider,
  ) {
    return call(onlyTwo: provider.onlyTwo);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myInProgressChallengesProvider';
}

/// See also [myInProgressChallenges].
class MyInProgressChallengesProvider
    extends AutoDisposeFutureProvider<List<ChallengeInProgressModel>> {
  /// See also [myInProgressChallenges].
  MyInProgressChallengesProvider({bool onlyTwo = false})
    : this._internal(
        (ref) => myInProgressChallenges(
          ref as MyInProgressChallengesRef,
          onlyTwo: onlyTwo,
        ),
        from: myInProgressChallengesProvider,
        name: r'myInProgressChallengesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myInProgressChallengesHash,
        dependencies: MyInProgressChallengesFamily._dependencies,
        allTransitiveDependencies:
            MyInProgressChallengesFamily._allTransitiveDependencies,
        onlyTwo: onlyTwo,
      );

  MyInProgressChallengesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.onlyTwo,
  }) : super.internal();

  final bool onlyTwo;

  @override
  Override overrideWith(
    FutureOr<List<ChallengeInProgressModel>> Function(
      MyInProgressChallengesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyInProgressChallengesProvider._internal(
        (ref) => create(ref as MyInProgressChallengesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        onlyTwo: onlyTwo,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChallengeInProgressModel>>
  createElement() {
    return _MyInProgressChallengesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyInProgressChallengesProvider && other.onlyTwo == onlyTwo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, onlyTwo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyInProgressChallengesRef
    on AutoDisposeFutureProviderRef<List<ChallengeInProgressModel>> {
  /// The parameter `onlyTwo` of this provider.
  bool get onlyTwo;
}

class _MyInProgressChallengesProviderElement
    extends AutoDisposeFutureProviderElement<List<ChallengeInProgressModel>>
    with MyInProgressChallengesRef {
  _MyInProgressChallengesProviderElement(super.provider);

  @override
  bool get onlyTwo => (origin as MyInProgressChallengesProvider).onlyTwo;
}

String _$mySuccessChallengesHash() =>
    r'95d005eec80994a28c20765d27b9a28ab78d01cf';

/// See also [mySuccessChallenges].
@ProviderFor(mySuccessChallenges)
const mySuccessChallengesProvider = MySuccessChallengesFamily();

/// See also [mySuccessChallenges].
class MySuccessChallengesFamily
    extends Family<AsyncValue<List<ChallengeInProgressModel>>> {
  /// See also [mySuccessChallenges].
  const MySuccessChallengesFamily();

  /// See also [mySuccessChallenges].
  MySuccessChallengesProvider call({bool onlyTwo = false}) {
    return MySuccessChallengesProvider(onlyTwo: onlyTwo);
  }

  @override
  MySuccessChallengesProvider getProviderOverride(
    covariant MySuccessChallengesProvider provider,
  ) {
    return call(onlyTwo: provider.onlyTwo);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mySuccessChallengesProvider';
}

/// See also [mySuccessChallenges].
class MySuccessChallengesProvider
    extends AutoDisposeFutureProvider<List<ChallengeInProgressModel>> {
  /// See also [mySuccessChallenges].
  MySuccessChallengesProvider({bool onlyTwo = false})
    : this._internal(
        (ref) => mySuccessChallenges(
          ref as MySuccessChallengesRef,
          onlyTwo: onlyTwo,
        ),
        from: mySuccessChallengesProvider,
        name: r'mySuccessChallengesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mySuccessChallengesHash,
        dependencies: MySuccessChallengesFamily._dependencies,
        allTransitiveDependencies:
            MySuccessChallengesFamily._allTransitiveDependencies,
        onlyTwo: onlyTwo,
      );

  MySuccessChallengesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.onlyTwo,
  }) : super.internal();

  final bool onlyTwo;

  @override
  Override overrideWith(
    FutureOr<List<ChallengeInProgressModel>> Function(
      MySuccessChallengesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MySuccessChallengesProvider._internal(
        (ref) => create(ref as MySuccessChallengesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        onlyTwo: onlyTwo,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChallengeInProgressModel>>
  createElement() {
    return _MySuccessChallengesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MySuccessChallengesProvider && other.onlyTwo == onlyTwo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, onlyTwo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MySuccessChallengesRef
    on AutoDisposeFutureProviderRef<List<ChallengeInProgressModel>> {
  /// The parameter `onlyTwo` of this provider.
  bool get onlyTwo;
}

class _MySuccessChallengesProviderElement
    extends AutoDisposeFutureProviderElement<List<ChallengeInProgressModel>>
    with MySuccessChallengesRef {
  _MySuccessChallengesProviderElement(super.provider);

  @override
  bool get onlyTwo => (origin as MySuccessChallengesProvider).onlyTwo;
}

String _$myFailedChallengesHash() =>
    r'332d3fb3a12b34ae0912d92300578649335a35e8';

/// See also [myFailedChallenges].
@ProviderFor(myFailedChallenges)
const myFailedChallengesProvider = MyFailedChallengesFamily();

/// See also [myFailedChallenges].
class MyFailedChallengesFamily
    extends Family<AsyncValue<List<ChallengeInProgressModel>>> {
  /// See also [myFailedChallenges].
  const MyFailedChallengesFamily();

  /// See also [myFailedChallenges].
  MyFailedChallengesProvider call({bool onlyTwo = false}) {
    return MyFailedChallengesProvider(onlyTwo: onlyTwo);
  }

  @override
  MyFailedChallengesProvider getProviderOverride(
    covariant MyFailedChallengesProvider provider,
  ) {
    return call(onlyTwo: provider.onlyTwo);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myFailedChallengesProvider';
}

/// See also [myFailedChallenges].
class MyFailedChallengesProvider
    extends AutoDisposeFutureProvider<List<ChallengeInProgressModel>> {
  /// See also [myFailedChallenges].
  MyFailedChallengesProvider({bool onlyTwo = false})
    : this._internal(
        (ref) =>
            myFailedChallenges(ref as MyFailedChallengesRef, onlyTwo: onlyTwo),
        from: myFailedChallengesProvider,
        name: r'myFailedChallengesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myFailedChallengesHash,
        dependencies: MyFailedChallengesFamily._dependencies,
        allTransitiveDependencies:
            MyFailedChallengesFamily._allTransitiveDependencies,
        onlyTwo: onlyTwo,
      );

  MyFailedChallengesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.onlyTwo,
  }) : super.internal();

  final bool onlyTwo;

  @override
  Override overrideWith(
    FutureOr<List<ChallengeInProgressModel>> Function(
      MyFailedChallengesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyFailedChallengesProvider._internal(
        (ref) => create(ref as MyFailedChallengesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        onlyTwo: onlyTwo,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChallengeInProgressModel>>
  createElement() {
    return _MyFailedChallengesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyFailedChallengesProvider && other.onlyTwo == onlyTwo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, onlyTwo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyFailedChallengesRef
    on AutoDisposeFutureProviderRef<List<ChallengeInProgressModel>> {
  /// The parameter `onlyTwo` of this provider.
  bool get onlyTwo;
}

class _MyFailedChallengesProviderElement
    extends AutoDisposeFutureProviderElement<List<ChallengeInProgressModel>>
    with MyFailedChallengesRef {
  _MyFailedChallengesProviderElement(super.provider);

  @override
  bool get onlyTwo => (origin as MyFailedChallengesProvider).onlyTwo;
}

String _$searchChallengesHash() => r'065450eb2d191ef0657fd876e50e7a03d5063c38';

/// See also [searchChallenges].
@ProviderFor(searchChallenges)
const searchChallengesProvider = SearchChallengesFamily();

/// See also [searchChallenges].
class SearchChallengesFamily
    extends Family<AsyncValue<List<SearchChallengeModel>>> {
  /// See also [searchChallenges].
  const SearchChallengesFamily();

  /// See also [searchChallenges].
  SearchChallengesProvider call({required String keyword, int page = 0}) {
    return SearchChallengesProvider(keyword: keyword, page: page);
  }

  @override
  SearchChallengesProvider getProviderOverride(
    covariant SearchChallengesProvider provider,
  ) {
    return call(keyword: provider.keyword, page: provider.page);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchChallengesProvider';
}

/// See also [searchChallenges].
class SearchChallengesProvider
    extends AutoDisposeFutureProvider<List<SearchChallengeModel>> {
  /// See also [searchChallenges].
  SearchChallengesProvider({required String keyword, int page = 0})
    : this._internal(
        (ref) => searchChallenges(
          ref as SearchChallengesRef,
          keyword: keyword,
          page: page,
        ),
        from: searchChallengesProvider,
        name: r'searchChallengesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchChallengesHash,
        dependencies: SearchChallengesFamily._dependencies,
        allTransitiveDependencies:
            SearchChallengesFamily._allTransitiveDependencies,
        keyword: keyword,
        page: page,
      );

  SearchChallengesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.keyword,
    required this.page,
  }) : super.internal();

  final String keyword;
  final int page;

  @override
  Override overrideWith(
    FutureOr<List<SearchChallengeModel>> Function(SearchChallengesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchChallengesProvider._internal(
        (ref) => create(ref as SearchChallengesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        keyword: keyword,
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SearchChallengeModel>> createElement() {
    return _SearchChallengesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchChallengesProvider &&
        other.keyword == keyword &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, keyword.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchChallengesRef
    on AutoDisposeFutureProviderRef<List<SearchChallengeModel>> {
  /// The parameter `keyword` of this provider.
  String get keyword;

  /// The parameter `page` of this provider.
  int get page;
}

class _SearchChallengesProviderElement
    extends AutoDisposeFutureProviderElement<List<SearchChallengeModel>>
    with SearchChallengesRef {
  _SearchChallengesProviderElement(super.provider);

  @override
  String get keyword => (origin as SearchChallengesProvider).keyword;
  @override
  int get page => (origin as SearchChallengesProvider).page;
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
String _$challengeLeaveNotifierHash() =>
    r'b3730af90553c42993450f3f38cb24c564a3ff8a';

/// See also [ChallengeLeaveNotifier].
@ProviderFor(ChallengeLeaveNotifier)
final challengeLeaveNotifierProvider =
    AutoDisposeNotifierProvider<
      ChallengeLeaveNotifier,
      AsyncValue<void>
    >.internal(
      ChallengeLeaveNotifier.new,
      name: r'challengeLeaveNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$challengeLeaveNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChallengeLeaveNotifier = AutoDisposeNotifier<AsyncValue<void>>;
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
    r'558fb00ff45dc4f321919d42368c1a94c415f602';

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
String _$imageVerifyNotifierHash() =>
    r'91d07f6c3d486d31cdeba206cb43812ca95edd7f';

/// See also [ImageVerifyNotifier].
@ProviderFor(ImageVerifyNotifier)
final imageVerifyNotifierProvider =
    AutoDisposeNotifierProvider<ImageVerifyNotifier, AsyncValue<int?>>.internal(
      ImageVerifyNotifier.new,
      name: r'imageVerifyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$imageVerifyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImageVerifyNotifier = AutoDisposeNotifier<AsyncValue<int?>>;
String _$articleUpdateNotifierHash() =>
    r'0b6c9f85f15de5b114787f2332ca7eae0668c6a2';

/// See also [ArticleUpdateNotifier].
@ProviderFor(ArticleUpdateNotifier)
final articleUpdateNotifierProvider =
    AutoDisposeNotifierProvider<
      ArticleUpdateNotifier,
      AsyncValue<CertificationPostModel?>
    >.internal(
      ArticleUpdateNotifier.new,
      name: r'articleUpdateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleUpdateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleUpdateNotifier =
    AutoDisposeNotifier<AsyncValue<CertificationPostModel?>>;
String _$articleDeleteNotifierHash() =>
    r'b11a8e3236a84b509fe694fdc747c45e450a211c';

/// See also [ArticleDeleteNotifier].
@ProviderFor(ArticleDeleteNotifier)
final articleDeleteNotifierProvider =
    AutoDisposeNotifierProvider<
      ArticleDeleteNotifier,
      AsyncValue<void>
    >.internal(
      ArticleDeleteNotifier.new,
      name: r'articleDeleteNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleDeleteNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleDeleteNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$articleCommentCreateNotifierHash() =>
    r'd84b900117d6f6fd84773769cae051987ce6bfcd';

/// See also [ArticleCommentCreateNotifier].
@ProviderFor(ArticleCommentCreateNotifier)
final articleCommentCreateNotifierProvider =
    AutoDisposeNotifierProvider<
      ArticleCommentCreateNotifier,
      AsyncValue<void>
    >.internal(
      ArticleCommentCreateNotifier.new,
      name: r'articleCommentCreateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleCommentCreateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleCommentCreateNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$articleCommentDeleteNotifierHash() =>
    r'b62243e175469fc7f81c2b36944aea57994438e8';

/// See also [ArticleCommentDeleteNotifier].
@ProviderFor(ArticleCommentDeleteNotifier)
final articleCommentDeleteNotifierProvider =
    AutoDisposeNotifierProvider<
      ArticleCommentDeleteNotifier,
      AsyncValue<void>
    >.internal(
      ArticleCommentDeleteNotifier.new,
      name: r'articleCommentDeleteNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleCommentDeleteNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleCommentDeleteNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$articleCommentUpdateNotifierHash() =>
    r'3c4af46b57926f9a695dedf7c01c7922c2d4ba5f';

/// See also [ArticleCommentUpdateNotifier].
@ProviderFor(ArticleCommentUpdateNotifier)
final articleCommentUpdateNotifierProvider =
    AutoDisposeNotifierProvider<
      ArticleCommentUpdateNotifier,
      AsyncValue<void>
    >.internal(
      ArticleCommentUpdateNotifier.new,
      name: r'articleCommentUpdateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleCommentUpdateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleCommentUpdateNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$articleLikeNotifierHash() =>
    r'edca8172ac97f7d19f7b645c5f0f928672a9ed1f';

/// See also [ArticleLikeNotifier].
@ProviderFor(ArticleLikeNotifier)
final articleLikeNotifierProvider =
    AutoDisposeNotifierProvider<ArticleLikeNotifier, AsyncValue<void>>.internal(
      ArticleLikeNotifier.new,
      name: r'articleLikeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$articleLikeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ArticleLikeNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$challengeDelegateNotifierHash() =>
    r'9ca847752fbd5dbe57f004bd395d80b69215d5eb';

/// See also [ChallengeDelegateNotifier].
@ProviderFor(ChallengeDelegateNotifier)
final challengeDelegateNotifierProvider =
    AutoDisposeNotifierProvider<
      ChallengeDelegateNotifier,
      AsyncValue<void>
    >.internal(
      ChallengeDelegateNotifier.new,
      name: r'challengeDelegateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$challengeDelegateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChallengeDelegateNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$challengeDeleteNotifierHash() =>
    r'fae50ca4d3884c1de44ceafd6bc2e89c775b2c54';

/// See also [ChallengeDeleteNotifier].
@ProviderFor(ChallengeDeleteNotifier)
final challengeDeleteNotifierProvider =
    AutoDisposeNotifierProvider<
      ChallengeDeleteNotifier,
      AsyncValue<void>
    >.internal(
      ChallengeDeleteNotifier.new,
      name: r'challengeDeleteNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$challengeDeleteNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChallengeDeleteNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$challengeParticipateNotifierHash() =>
    r'f6af3d6d99c942b164911cb504c4c57825eeb4d2';

/// See also [ChallengeParticipateNotifier].
@ProviderFor(ChallengeParticipateNotifier)
final challengeParticipateNotifierProvider =
    AutoDisposeNotifierProvider<
      ChallengeParticipateNotifier,
      AsyncValue<void>
    >.internal(
      ChallengeParticipateNotifier.new,
      name: r'challengeParticipateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$challengeParticipateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChallengeParticipateNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
