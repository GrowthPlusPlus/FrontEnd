// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postCommentsHash() => r'078468e7edde7672d4d1e91472df38af619eb8b7';

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

/// See also [postComments].
@ProviderFor(postComments)
const postCommentsProvider = PostCommentsFamily();

/// See also [postComments].
class PostCommentsFamily extends Family<AsyncValue<List<Comment>>> {
  /// See also [postComments].
  const PostCommentsFamily();

  /// See also [postComments].
  PostCommentsProvider call({required int postId, int page = 0}) {
    return PostCommentsProvider(postId: postId, page: page);
  }

  @override
  PostCommentsProvider getProviderOverride(
    covariant PostCommentsProvider provider,
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
  String? get name => r'postCommentsProvider';
}

/// See also [postComments].
class PostCommentsProvider extends AutoDisposeFutureProvider<List<Comment>> {
  /// See also [postComments].
  PostCommentsProvider({required int postId, int page = 0})
    : this._internal(
        (ref) =>
            postComments(ref as PostCommentsRef, postId: postId, page: page),
        from: postCommentsProvider,
        name: r'postCommentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$postCommentsHash,
        dependencies: PostCommentsFamily._dependencies,
        allTransitiveDependencies:
            PostCommentsFamily._allTransitiveDependencies,
        postId: postId,
        page: page,
      );

  PostCommentsProvider._internal(
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
    FutureOr<List<Comment>> Function(PostCommentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostCommentsProvider._internal(
        (ref) => create(ref as PostCommentsRef),
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
  AutoDisposeFutureProviderElement<List<Comment>> createElement() {
    return _PostCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsProvider &&
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
mixin PostCommentsRef on AutoDisposeFutureProviderRef<List<Comment>> {
  /// The parameter `postId` of this provider.
  int get postId;

  /// The parameter `page` of this provider.
  int get page;
}

class _PostCommentsProviderElement
    extends AutoDisposeFutureProviderElement<List<Comment>>
    with PostCommentsRef {
  _PostCommentsProviderElement(super.provider);

  @override
  int get postId => (origin as PostCommentsProvider).postId;
  @override
  int get page => (origin as PostCommentsProvider).page;
}

String _$commentCreateNotifierHash() =>
    r'c125a85e3dd166344703c77d2e7992c53fb9154a';

/// See also [CommentCreateNotifier].
@ProviderFor(CommentCreateNotifier)
final commentCreateNotifierProvider =
    AutoDisposeNotifierProvider<
      CommentCreateNotifier,
      AsyncValue<void>
    >.internal(
      CommentCreateNotifier.new,
      name: r'commentCreateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$commentCreateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommentCreateNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$commentUpdateNotifierHash() =>
    r'24745c04e7d1a4e433fd6df4ef4a55c70158f6cd';

/// See also [CommentUpdateNotifier].
@ProviderFor(CommentUpdateNotifier)
final commentUpdateNotifierProvider =
    AutoDisposeNotifierProvider<
      CommentUpdateNotifier,
      AsyncValue<void>
    >.internal(
      CommentUpdateNotifier.new,
      name: r'commentUpdateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$commentUpdateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommentUpdateNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$commentDeleteNotifierHash() =>
    r'25843072cf5f2a8d4461ca80c8746909cfe46261';

/// See also [CommentDeleteNotifier].
@ProviderFor(CommentDeleteNotifier)
final commentDeleteNotifierProvider =
    AutoDisposeNotifierProvider<
      CommentDeleteNotifier,
      AsyncValue<void>
    >.internal(
      CommentDeleteNotifier.new,
      name: r'commentDeleteNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$commentDeleteNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommentDeleteNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
