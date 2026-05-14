// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeDetailHash() => r'ea0b246d99206d198ec31081a6a32ee83aaee20c';

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
class ChallengeDetailFamily extends Family<AsyncValue<ChallengeDetail>> {
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
    extends AutoDisposeFutureProvider<ChallengeDetail> {
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
    FutureOr<ChallengeDetail> Function(ChallengeDetailRef provider) create,
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
  AutoDisposeFutureProviderElement<ChallengeDetail> createElement() {
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
mixin ChallengeDetailRef on AutoDisposeFutureProviderRef<ChallengeDetail> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _ChallengeDetailProviderElement
    extends AutoDisposeFutureProviderElement<ChallengeDetail>
    with ChallengeDetailRef {
  _ChallengeDetailProviderElement(super.provider);

  @override
  int get challengeId => (origin as ChallengeDetailProvider).challengeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
