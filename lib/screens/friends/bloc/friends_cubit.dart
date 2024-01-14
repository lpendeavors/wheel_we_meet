import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/user_repository.dart';
import 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final UserRepository _userRepository;

  StreamSubscription? _friendsSubscription;
  StreamSubscription? _requestsSubscription;

  FriendsCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(FriendsInitial());

  void loadFriends() {
    try {
      emit(FriendsLoading());

      _friendsSubscription?.cancel();
      _friendsSubscription = _userRepository.getFriends().listen(
        (friends) {
          final currentState = state;
          if (currentState is FriendsLoaded) {
            emit(FriendsLoaded(friends, currentState.requests));
          } else {
            emit(FriendsLoaded(friends, []));
          }
        },
        onError: (error) => emit(FriendsError(error.toString())),
      );

      _requestsSubscription?.cancel();
      _requestsSubscription = _userRepository.getFriendRequests().listen(
        (requests) {
          final currentState = state;
          if (currentState is FriendsLoaded) {
            emit(FriendsLoaded(currentState.friends, requests));
          } else {
            emit(FriendsLoaded([], requests));
          }
        },
        onError: (error) => emit(FriendsError(error.toString())),
      );
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void addFriend(String email) {
    try {
      _userRepository.sendFriendRequest(email: email);
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void deleteFriend(String friendId) {
    try {
      _userRepository.unfriend(friendUserId: friendId);
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void acceptFriendRequest(String friendId) {
    print('accept $friendId');
    try {
      _userRepository.acceptFriendRequest(friendUserId: friendId);
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  void cancelFriendRequest(String friendId) {
    try {
      _userRepository.cancelFriendRequest(friendUserId: friendId);
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _friendsSubscription?.cancel();
    _requestsSubscription?.cancel();
    return super.close();
  }
}
