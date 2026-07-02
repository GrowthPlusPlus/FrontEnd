// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postDetailHash() => r'4c7ecb10d1517df7f808b4645bd6cc6047aab5c6';

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

/// See also [postDetail].
@ProviderFor(postDetail)
const postDetailProvider = PostDetailFamily();

/// See also [postDetail].
class PostDetailFamily extends Family<AsyncValue<Post>> {
  /// See also [postDetail].
  const PostDetailFamily();

  /// See also [postDetail].
  PostDetailProvider call({required int postId}) {
    return PostDetailProvider(postId: postId);
  }

  @override
  PostDetailProvider getProviderOverride(
    covariant PostDetailProvider provider,
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
  String? get name => r'postDetailProvider';
}

/// See also [postDetail].
class PostDetailProvider extends AutoDisposeFutureProvider<Post> {
  /// See also [postDetail].
  PostDetailProvider({required int postId})
    : this._internal(
        (ref) => postDetail(ref as PostDetailRef, postId: postId),
        from: postDetailProvider,
        name: r'postDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$postDetailHash,
        dependencies: PostDetailFamily._dependencies,
        allTransitiveDependencies: PostDetailFamily._allTransitiveDependencies,
        postId: postId,
      );

  PostDetailProvider._internal(
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
    FutureOr<Post> Function(PostDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostDetailProvider._internal(
        (ref) => create(ref as PostDetailRef),
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
  AutoDisposeFutureProviderElement<Post> createElement() {
    return _PostDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostDetailProvider && other.postId == postId;
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
mixin PostDetailRef on AutoDisposeFutureProviderRef<Post> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _PostDetailProviderElement extends AutoDisposeFutureProviderElement<Post>
    with PostDetailRef {
  _PostDetailProviderElement(super.provider);

  @override
  int get postId => (origin as PostDetailProvider).postId;
}

String _$postCreateNotifierHash() =>
    r'2d9392f118e628a9ab3f16ecd2d524fbf17e99bd';

/// See also [PostCreateNotifier].
@ProviderFor(PostCreateNotifier)
final postCreateNotifierProvider =
    AutoDisposeNotifierProvider<PostCreateNotifier, AsyncValue<Post?>>.internal(
      PostCreateNotifier.new,
      name: r'postCreateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postCreateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PostCreateNotifier = AutoDisposeNotifier<AsyncValue<Post?>>;
String _$postUpdateNotifierHash() =>
    r'ffadccd22bb2faec7b7f4c8b11493fb4c8695351';

/// See also [PostUpdateNotifier].
@ProviderFor(PostUpdateNotifier)
final postUpdateNotifierProvider =
    AutoDisposeNotifierProvider<PostUpdateNotifier, AsyncValue<Post?>>.internal(
      PostUpdateNotifier.new,
      name: r'postUpdateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postUpdateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PostUpdateNotifier = AutoDisposeNotifier<AsyncValue<Post?>>;
String _$postDeleteNotifierHash() =>
    r'20a8b5cfcb2ef93011a74ddef163e329cd192cb2';

/// See also [PostDeleteNotifier].
@ProviderFor(PostDeleteNotifier)
final postDeleteNotifierProvider =
    AutoDisposeNotifierProvider<PostDeleteNotifier, AsyncValue<void>>.internal(
      PostDeleteNotifier.new,
      name: r'postDeleteNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postDeleteNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PostDeleteNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$postLikeNotifierHash() => r'babbf64cb6d1c62edec7a8ee5635fa76b29bf63c';

/// See also [PostLikeNotifier].
@ProviderFor(PostLikeNotifier)
final postLikeNotifierProvider =
    AutoDisposeNotifierProvider<PostLikeNotifier, AsyncValue<void>>.internal(
      PostLikeNotifier.new,
      name: r'postLikeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postLikeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PostLikeNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
