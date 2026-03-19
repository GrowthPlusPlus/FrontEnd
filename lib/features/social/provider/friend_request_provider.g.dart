// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$receivedRequestsHash() => r'4b5c706f34051662afd50c7b5f97fd3ea4258799';

/// See also [ReceivedRequests].
@ProviderFor(ReceivedRequests)
final receivedRequestsProvider =
    AutoDisposeAsyncNotifierProvider<
      ReceivedRequests,
      List<FriendRequestCard>
    >.internal(
      ReceivedRequests.new,
      name: r'receivedRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$receivedRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReceivedRequests = AutoDisposeAsyncNotifier<List<FriendRequestCard>>;
String _$sentRequestsHash() => r'8416bec6bc2187d5ccfeb4aacc1dc6c248b552a6';

/// See also [SentRequests].
@ProviderFor(SentRequests)
final sentRequestsProvider =
    AutoDisposeAsyncNotifierProvider<
      SentRequests,
      List<FriendRequestCard>
    >.internal(
      SentRequests.new,
      name: r'sentRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sentRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SentRequests = AutoDisposeAsyncNotifier<List<FriendRequestCard>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
