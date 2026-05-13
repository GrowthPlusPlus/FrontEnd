// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_challenge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myInProgressChallengesHash() =>
    r'97c9400ea42582ca7c6e7e2390905d47704bbf5b';

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

/// See also [myInProgressChallenges].
@ProviderFor(myInProgressChallenges)
const myInProgressChallengesProvider = MyInProgressChallengesFamily();

/// See also [myInProgressChallenges].
class MyInProgressChallengesFamily
    extends Family<AsyncValue<List<MyPageChallengeCard>>> {
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
    extends AutoDisposeFutureProvider<List<MyPageChallengeCard>> {
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
    FutureOr<List<MyPageChallengeCard>> Function(
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
  AutoDisposeFutureProviderElement<List<MyPageChallengeCard>> createElement() {
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
    on AutoDisposeFutureProviderRef<List<MyPageChallengeCard>> {
  /// The parameter `onlyTwo` of this provider.
  bool get onlyTwo;
}

class _MyInProgressChallengesProviderElement
    extends AutoDisposeFutureProviderElement<List<MyPageChallengeCard>>
    with MyInProgressChallengesRef {
  _MyInProgressChallengesProviderElement(super.provider);

  @override
  bool get onlyTwo => (origin as MyInProgressChallengesProvider).onlyTwo;
}

String _$mySuccessChallengesHash() =>
    r'4c71c6dd9942b1bee097455700a66099eb08da0c';

/// See also [mySuccessChallenges].
@ProviderFor(mySuccessChallenges)
const mySuccessChallengesProvider = MySuccessChallengesFamily();

/// See also [mySuccessChallenges].
class MySuccessChallengesFamily
    extends Family<AsyncValue<List<MyPageChallengeCard>>> {
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
    extends AutoDisposeFutureProvider<List<MyPageChallengeCard>> {
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
    FutureOr<List<MyPageChallengeCard>> Function(
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
  AutoDisposeFutureProviderElement<List<MyPageChallengeCard>> createElement() {
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
    on AutoDisposeFutureProviderRef<List<MyPageChallengeCard>> {
  /// The parameter `onlyTwo` of this provider.
  bool get onlyTwo;
}

class _MySuccessChallengesProviderElement
    extends AutoDisposeFutureProviderElement<List<MyPageChallengeCard>>
    with MySuccessChallengesRef {
  _MySuccessChallengesProviderElement(super.provider);

  @override
  bool get onlyTwo => (origin as MySuccessChallengesProvider).onlyTwo;
}

String _$myFailedChallengesHash() =>
    r'dcff0a445e60508d54100b481c6584282761f31e';

/// See also [myFailedChallenges].
@ProviderFor(myFailedChallenges)
const myFailedChallengesProvider = MyFailedChallengesFamily();

/// See also [myFailedChallenges].
class MyFailedChallengesFamily
    extends Family<AsyncValue<List<MyPageChallengeCard>>> {
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
    extends AutoDisposeFutureProvider<List<MyPageChallengeCard>> {
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
    FutureOr<List<MyPageChallengeCard>> Function(MyFailedChallengesRef provider)
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
  AutoDisposeFutureProviderElement<List<MyPageChallengeCard>> createElement() {
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
    on AutoDisposeFutureProviderRef<List<MyPageChallengeCard>> {
  /// The parameter `onlyTwo` of this provider.
  bool get onlyTwo;
}

class _MyFailedChallengesProviderElement
    extends AutoDisposeFutureProviderElement<List<MyPageChallengeCard>>
    with MyFailedChallengesRef {
  _MyFailedChallengesProviderElement(super.provider);

  @override
  bool get onlyTwo => (origin as MyFailedChallengesProvider).onlyTwo;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
