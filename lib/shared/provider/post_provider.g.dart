// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyChallengePostsHash() =>
    r'dfcde62130fba3d3465ea6297f7d4b4c294b58f9';

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

/// See also [monthlyChallengePosts].
@ProviderFor(monthlyChallengePosts)
const monthlyChallengePostsProvider = MonthlyChallengePostsFamily();

/// See also [monthlyChallengePosts].
class MonthlyChallengePostsFamily
    extends Family<AsyncValue<List<CalendarPost>>> {
  /// See also [monthlyChallengePosts].
  const MonthlyChallengePostsFamily();

  /// See also [monthlyChallengePosts].
  MonthlyChallengePostsProvider call({
    required int challengeId,
    required int year,
    required int month,
  }) {
    return MonthlyChallengePostsProvider(
      challengeId: challengeId,
      year: year,
      month: month,
    );
  }

  @override
  MonthlyChallengePostsProvider getProviderOverride(
    covariant MonthlyChallengePostsProvider provider,
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
  String? get name => r'monthlyChallengePostsProvider';
}

/// See also [monthlyChallengePosts].
class MonthlyChallengePostsProvider
    extends AutoDisposeFutureProvider<List<CalendarPost>> {
  /// See also [monthlyChallengePosts].
  MonthlyChallengePostsProvider({
    required int challengeId,
    required int year,
    required int month,
  }) : this._internal(
         (ref) => monthlyChallengePosts(
           ref as MonthlyChallengePostsRef,
           challengeId: challengeId,
           year: year,
           month: month,
         ),
         from: monthlyChallengePostsProvider,
         name: r'monthlyChallengePostsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$monthlyChallengePostsHash,
         dependencies: MonthlyChallengePostsFamily._dependencies,
         allTransitiveDependencies:
             MonthlyChallengePostsFamily._allTransitiveDependencies,
         challengeId: challengeId,
         year: year,
         month: month,
       );

  MonthlyChallengePostsProvider._internal(
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
    FutureOr<List<CalendarPost>> Function(MonthlyChallengePostsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyChallengePostsProvider._internal(
        (ref) => create(ref as MonthlyChallengePostsRef),
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
  AutoDisposeFutureProviderElement<List<CalendarPost>> createElement() {
    return _MonthlyChallengePostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyChallengePostsProvider &&
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
mixin MonthlyChallengePostsRef
    on AutoDisposeFutureProviderRef<List<CalendarPost>> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _MonthlyChallengePostsProviderElement
    extends AutoDisposeFutureProviderElement<List<CalendarPost>>
    with MonthlyChallengePostsRef {
  _MonthlyChallengePostsProviderElement(super.provider);

  @override
  int get challengeId => (origin as MonthlyChallengePostsProvider).challengeId;
  @override
  int get year => (origin as MonthlyChallengePostsProvider).year;
  @override
  int get month => (origin as MonthlyChallengePostsProvider).month;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
