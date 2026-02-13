// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeMembersHash() => r'64f129d20a062a2443e2fac5867db217ffcb1054';

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

/// See also [challengeMembers].
@ProviderFor(challengeMembers)
const challengeMembersProvider = ChallengeMembersFamily();

/// See also [challengeMembers].
class ChallengeMembersFamily extends Family<AsyncValue<List<ChallengeMember>>> {
  /// See also [challengeMembers].
  const ChallengeMembersFamily();

  /// See also [challengeMembers].
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

/// See also [challengeMembers].
class ChallengeMembersProvider
    extends AutoDisposeFutureProvider<List<ChallengeMember>> {
  /// See also [challengeMembers].
  ChallengeMembersProvider(MemberFilter filter)
    : this._internal(
        (ref) => challengeMembers(ref as ChallengeMembersRef, filter),
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
  Override overrideWith(
    FutureOr<List<ChallengeMember>> Function(ChallengeMembersRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChallengeMembersProvider._internal(
        (ref) => create(ref as ChallengeMembersRef),
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
  AutoDisposeFutureProviderElement<List<ChallengeMember>> createElement() {
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
mixin ChallengeMembersRef
    on AutoDisposeFutureProviderRef<List<ChallengeMember>> {
  /// The parameter `filter` of this provider.
  MemberFilter get filter;
}

class _ChallengeMembersProviderElement
    extends AutoDisposeFutureProviderElement<List<ChallengeMember>>
    with ChallengeMembersRef {
  _ChallengeMembersProviderElement(super.provider);

  @override
  MemberFilter get filter => (origin as ChallengeMembersProvider).filter;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
