import '../../../models/user_entity.dart';

abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<UserEntity> friends;
  final List<UserEntity> requests;

  FriendsLoaded(this.friends, this.requests);
}

class FriendsError extends FriendsState {
  final String message;
  FriendsError(this.message);
}
