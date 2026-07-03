// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeMembersHash() => r'11a81846e1a973d4d4fe9e85496a38c3ac86352e';

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

abstract class _$ChallengeMembers
    extends BuildlessAutoDisposeAsyncNotifier<List<User>> {
  late final MemberFilter filter;

  FutureOr<List<User>> build(MemberFilter filter);
}

/// See also [ChallengeMembers].
@ProviderFor(ChallengeMembers)
const challengeMembersProvider = ChallengeMembersFamily();

/// See also [ChallengeMembers].
class ChallengeMembersFamily extends Family<AsyncValue<List<User>>> {
  /// See also [ChallengeMembers].
  const ChallengeMembersFamily();

  /// See also [ChallengeMembers].
  ChallengeMembersProvider call(MemberFilter filter) {
    return ChallengeMembersProvider(filter);
  }

  @override
  ChallengeMembersProvider getProviderOverride(
    covariant ChallengeMembersProvider provider,
  ) {
    return call(provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'challengeMembersProvider';
}

/// See also [ChallengeMembers].
class ChallengeMembersProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChallengeMembers, List<User>> {
  /// See also [ChallengeMembers].
  ChallengeMembersProvider(MemberFilter filter)
    : this._internal(
        () => ChallengeMembers()..filter = filter,
        from: challengeMembersProvider,
        name: r'challengeMembersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$challengeMembersHash,
        dependencies: ChallengeMembersFamily._dependencies,
        allTransitiveDependencies:
            ChallengeMembersFamily._allTransitiveDependencies,
        filter: filter,
      );

  ChallengeMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final MemberFilter filter;

  @override
  FutureOr<List<User>> runNotifierBuild(covariant ChallengeMembers notifier) {
    return notifier.build(filter);
  }

  @override
  Override overrideWith(ChallengeMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChallengeMembersProvider._internal(
        () => create()..filter = filter,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChallengeMembers, List<User>>
  createElement() {
    return _ChallengeMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeMembersProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChallengeMembersRef on AutoDisposeAsyncNotifierProviderRef<List<User>> {
  /// The parameter `filter` of this provider.
  MemberFilter get filter;
}

class _ChallengeMembersProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ChallengeMembers, List<User>>
    with ChallengeMembersRef {
  _ChallengeMembersProviderElement(super.provider);

  @override
  MemberFilter get filter => (origin as ChallengeMembersProvider).filter;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
