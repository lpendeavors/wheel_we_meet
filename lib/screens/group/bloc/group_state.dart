import 'group_vm.dart';

abstract class GroupState {}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupsLoaded extends GroupState {
  final List<GroupVM> groups;

  GroupsLoaded(this.groups);
}

class GroupsSearched extends GroupState {
  final List<GroupVM> groups;

  GroupsSearched(this.groups);
}

class GroupCreated extends GroupState {
  final String groupId;

  GroupCreated(this.groupId);
}

class GroupJoined extends GroupState {
  final String groupId;

  GroupJoined(this.groupId);
}

class GroupError extends GroupState {
  final String message;

  GroupError(this.message);
}

class FriendsLoading extends GroupState {}

class FriendsLoaded extends GroupState {
  final List<FriendVM> friends;

  FriendsLoaded(this.friends);
}
