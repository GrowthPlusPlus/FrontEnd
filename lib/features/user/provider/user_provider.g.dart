// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserHash() => r'1cd77fb5bb48fa22fbd7a130413d96bac74fdc3d';

/// See also [CurrentUser].
@ProviderFor(CurrentUser)
final currentUserProvider = NotifierProvider<CurrentUser, User?>.internal(
  CurrentUser.new,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentUser = Notifier<User?>;
String _$myProfileHash() => r'a2ae41d2429d95cb9cbdecd38b5825067b6b9ebc';

/// See also [MyProfile].
@ProviderFor(MyProfile)
final myProfileProvider =
    AutoDisposeAsyncNotifierProvider<MyProfile, UserDetail>.internal(
      MyProfile.new,
      name: r'myProfileProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myProfileHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyProfile = AutoDisposeAsyncNotifier<UserDetail>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
