// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeStatsHash() => r'ab18d5fc2d586a987b36fe8fec664ea5a49f175b';

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

/// See also [challengeStats].
@ProviderFor(challengeStats)
const challengeStatsProvider = ChallengeStatsFamily();

/// See also [challengeStats].
class ChallengeStatsFamily extends Family<AsyncValue<ChallengeStats>> {
  /// See also [challengeStats].
  const ChallengeStatsFamily();

  /// See also [challengeStats].
  ChallengeStatsProvider call(int challengeId) {
    return ChallengeStatsProvider(challengeId);
  }

  @override
  ChallengeStatsProvider getProviderOverride(
    covariant ChallengeStatsProvider provider,
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
  String? get name => r'challengeStatsProvider';
}

/// See also [challengeStats].
class ChallengeStatsProvider extends AutoDisposeFutureProvider<ChallengeStats> {
  /// See also [challengeStats].
  ChallengeStatsProvider(int challengeId)
    : this._internal(
        (ref) => challengeStats(ref as ChallengeStatsRef, challengeId),
        from: challengeStatsProvider,
        name: r'challengeStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$challengeStatsHash,
        dependencies: ChallengeStatsFamily._dependencies,
        allTransitiveDependencies:
            ChallengeStatsFamily._allTransitiveDependencies,
        challengeId: challengeId,
      );

  ChallengeStatsProvider._internal(
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
    FutureOr<ChallengeStats> Function(ChallengeStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChallengeStatsProvider._internal(
        (ref) => create(ref as ChallengeStatsRef),
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
  AutoDisposeFutureProviderElement<ChallengeStats> createElement() {
    return _ChallengeStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeStatsProvider && other.challengeId == challengeId;
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
mixin ChallengeStatsRef on AutoDisposeFutureProviderRef<ChallengeStats> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _ChallengeStatsProviderElement
    extends AutoDisposeFutureProviderElement<ChallengeStats>
    with ChallengeStatsRef {
  _ChallengeStatsProviderElement(super.provider);

  @override
  int get challengeId => (origin as ChallengeStatsProvider).challengeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
