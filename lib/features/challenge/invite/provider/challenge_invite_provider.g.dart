// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_invite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$challengeInviteHash() => r'df75e09f6a485ad010ee00e52251f1247a94a5c3';

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

/// 챌린지 초대 정보 Provider
/// - ChallengeInviteContent에서 ref.watch(challengeInviteInfoProvider(challengeId))로 사용
///
/// Copied from [challengeInvite].
@ProviderFor(challengeInvite)
const challengeInviteProvider = ChallengeInviteFamily();

/// 챌린지 초대 정보 Provider
/// - ChallengeInviteContent에서 ref.watch(challengeInviteInfoProvider(challengeId))로 사용
///
/// Copied from [challengeInvite].
class ChallengeInviteFamily
    extends Family<AsyncValue<ChallengeInviteResponse>> {
  /// 챌린지 초대 정보 Provider
  /// - ChallengeInviteContent에서 ref.watch(challengeInviteInfoProvider(challengeId))로 사용
  ///
  /// Copied from [challengeInvite].
  const ChallengeInviteFamily();

  /// 챌린지 초대 정보 Provider
  /// - ChallengeInviteContent에서 ref.watch(challengeInviteInfoProvider(challengeId))로 사용
  ///
  /// Copied from [challengeInvite].
  ChallengeInviteProvider call(int challengeId) {
    return ChallengeInviteProvider(challengeId);
  }

  @override
  ChallengeInviteProvider getProviderOverride(
    covariant ChallengeInviteProvider provider,
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
  String? get name => r'challengeInviteProvider';
}

/// 챌린지 초대 정보 Provider
/// - ChallengeInviteContent에서 ref.watch(challengeInviteInfoProvider(challengeId))로 사용
///
/// Copied from [challengeInvite].
class ChallengeInviteProvider
    extends AutoDisposeFutureProvider<ChallengeInviteResponse> {
  /// 챌린지 초대 정보 Provider
  /// - ChallengeInviteContent에서 ref.watch(challengeInviteInfoProvider(challengeId))로 사용
  ///
  /// Copied from [challengeInvite].
  ChallengeInviteProvider(int challengeId)
    : this._internal(
        (ref) => challengeInvite(ref as ChallengeInviteRef, challengeId),
        from: challengeInviteProvider,
        name: r'challengeInviteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$challengeInviteHash,
        dependencies: ChallengeInviteFamily._dependencies,
        allTransitiveDependencies:
            ChallengeInviteFamily._allTransitiveDependencies,
        challengeId: challengeId,
      );

  ChallengeInviteProvider._internal(
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
    FutureOr<ChallengeInviteResponse> Function(ChallengeInviteRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChallengeInviteProvider._internal(
        (ref) => create(ref as ChallengeInviteRef),
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
  AutoDisposeFutureProviderElement<ChallengeInviteResponse> createElement() {
    return _ChallengeInviteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeInviteProvider && other.challengeId == challengeId;
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
mixin ChallengeInviteRef
    on AutoDisposeFutureProviderRef<ChallengeInviteResponse> {
  /// The parameter `challengeId` of this provider.
  int get challengeId;
}

class _ChallengeInviteProviderElement
    extends AutoDisposeFutureProviderElement<ChallengeInviteResponse>
    with ChallengeInviteRef {
  _ChallengeInviteProviderElement(super.provider);

  @override
  int get challengeId => (origin as ChallengeInviteProvider).challengeId;
}

String _$challengeIdByInviteCodeHash() =>
    r'2f1f3b9f3a4ede97e6a863bf513112d4aee033b8';

/// See also [challengeIdByInviteCode].
@ProviderFor(challengeIdByInviteCode)
const challengeIdByInviteCodeProvider = ChallengeIdByInviteCodeFamily();

/// See also [challengeIdByInviteCode].
class ChallengeIdByInviteCodeFamily
    extends Family<AsyncValue<ChallengeDeepLinkResponse>> {
  /// See also [challengeIdByInviteCode].
  const ChallengeIdByInviteCodeFamily();

  /// See also [challengeIdByInviteCode].
  ChallengeIdByInviteCodeProvider call(String inviteCode) {
    return ChallengeIdByInviteCodeProvider(inviteCode);
  }

  @override
  ChallengeIdByInviteCodeProvider getProviderOverride(
    covariant ChallengeIdByInviteCodeProvider provider,
  ) {
    return call(provider.inviteCode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'challengeIdByInviteCodeProvider';
}

/// See also [challengeIdByInviteCode].
class ChallengeIdByInviteCodeProvider
    extends AutoDisposeFutureProvider<ChallengeDeepLinkResponse> {
  /// See also [challengeIdByInviteCode].
  ChallengeIdByInviteCodeProvider(String inviteCode)
    : this._internal(
        (ref) => challengeIdByInviteCode(
          ref as ChallengeIdByInviteCodeRef,
          inviteCode,
        ),
        from: challengeIdByInviteCodeProvider,
        name: r'challengeIdByInviteCodeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$challengeIdByInviteCodeHash,
        dependencies: ChallengeIdByInviteCodeFamily._dependencies,
        allTransitiveDependencies:
            ChallengeIdByInviteCodeFamily._allTransitiveDependencies,
        inviteCode: inviteCode,
      );

  ChallengeIdByInviteCodeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.inviteCode,
  }) : super.internal();

  final String inviteCode;

  @override
  Override overrideWith(
    FutureOr<ChallengeDeepLinkResponse> Function(
      ChallengeIdByInviteCodeRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChallengeIdByInviteCodeProvider._internal(
        (ref) => create(ref as ChallengeIdByInviteCodeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        inviteCode: inviteCode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChallengeDeepLinkResponse> createElement() {
    return _ChallengeIdByInviteCodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeIdByInviteCodeProvider &&
        other.inviteCode == inviteCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inviteCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChallengeIdByInviteCodeRef
    on AutoDisposeFutureProviderRef<ChallengeDeepLinkResponse> {
  /// The parameter `inviteCode` of this provider.
  String get inviteCode;
}

class _ChallengeIdByInviteCodeProviderElement
    extends AutoDisposeFutureProviderElement<ChallengeDeepLinkResponse>
    with ChallengeIdByInviteCodeRef {
  _ChallengeIdByInviteCodeProviderElement(super.provider);

  @override
  String get inviteCode =>
      (origin as ChallengeIdByInviteCodeProvider).inviteCode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
