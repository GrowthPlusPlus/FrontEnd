// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiRecommendationHash() => r'90ca6a9c155eaf19f39c8ef6ebc589e287b93686';

/// See also [aiRecommendation].
@ProviderFor(aiRecommendation)
final aiRecommendationProvider =
    AutoDisposeFutureProvider<List<SearchChallengeCard>>.internal(
      aiRecommendation,
      name: r'aiRecommendationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiRecommendationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiRecommendationRef =
    AutoDisposeFutureProviderRef<List<SearchChallengeCard>>;
String _$feedNotifierHash() => r'58f6bfea36959e5344b16506c194b07fbbcce5f5';

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

abstract class _$FeedNotifier extends BuildlessAutoDisposeNotifier<FeedState> {
  late final String apiPath;

  FeedState build(String apiPath);
}

/// See also [FeedNotifier].
@ProviderFor(FeedNotifier)
const feedNotifierProvider = FeedNotifierFamily();

/// See also [FeedNotifier].
class FeedNotifierFamily extends Family<FeedState> {
  /// See also [FeedNotifier].
  const FeedNotifierFamily();

  /// See also [FeedNotifier].
  FeedNotifierProvider call(String apiPath) {
    return FeedNotifierProvider(apiPath);
  }

  @override
  FeedNotifierProvider getProviderOverride(
    covariant FeedNotifierProvider provider,
  ) {
    return call(provider.apiPath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedNotifierProvider';
}

/// See also [FeedNotifier].
class FeedNotifierProvider
    extends AutoDisposeNotifierProviderImpl<FeedNotifier, FeedState> {
  /// See also [FeedNotifier].
  FeedNotifierProvider(String apiPath)
    : this._internal(
        () => FeedNotifier()..apiPath = apiPath,
        from: feedNotifierProvider,
        name: r'feedNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedNotifierHash,
        dependencies: FeedNotifierFamily._dependencies,
        allTransitiveDependencies:
            FeedNotifierFamily._allTransitiveDependencies,
        apiPath: apiPath,
      );

  FeedNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.apiPath,
  }) : super.internal();

  final String apiPath;

  @override
  FeedState runNotifierBuild(covariant FeedNotifier notifier) {
    return notifier.build(apiPath);
  }

  @override
  Override overrideWith(FeedNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeedNotifierProvider._internal(
        () => create()..apiPath = apiPath,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        apiPath: apiPath,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<FeedNotifier, FeedState> createElement() {
    return _FeedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedNotifierProvider && other.apiPath == apiPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, apiPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedNotifierRef on AutoDisposeNotifierProviderRef<FeedState> {
  /// The parameter `apiPath` of this provider.
  String get apiPath;
}

class _FeedNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<FeedNotifier, FeedState>
    with FeedNotifierRef {
  _FeedNotifierProviderElement(super.provider);

  @override
  String get apiPath => (origin as FeedNotifierProvider).apiPath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
