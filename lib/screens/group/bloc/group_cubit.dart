import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/models.dart';
import '../../../repositories/repositories.dart';
import 'group_state.dart';
import 'group_vm.dart';

class GroupCubit extends Cubit<GroupState> {
  final ConversationRepository conversationRepository;
  final UserRepository userRepository;

  StreamSubscription? _groupsStreamSubscription;
  StreamSubscription? _friendsStreamSubscription;

  List<GroupVM> allGroups = [];

  GroupCubit({
    required this.userRepository,
    required this.conversationRepository,
  }) : super(GroupInitial());

  @override
  Future<void> close() {
    _groupsStreamSubscription?.cancel();
    _friendsStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> loadGroups() async {
    try {
      emit(GroupLoading());
      _groupsStreamSubscription?.cancel();
      _groupsStreamSubscription = conversationRepository
          .getPublicConversations()
          .listen((conversations) async {
        final vms = _toGroupVM(conversations);
        allGroups = vms;
        emit(GroupsLoaded(vms));
      });
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> searchGroups(String query) async {
    if (state is GroupsLoaded) {
      if (query.isEmpty) {
        emit(GroupsLoaded(allGroups));
        return;
      }
      var filteredGroups = allGroups
          .where(
            (group) => group.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      emit(GroupsLoaded(filteredGroups));
    } else {
      emit(GroupError('Groups are not loaded yet'));
    }
  }

  Future<void> loadFriends() async {
    try {
      emit(GroupLoading());
      _friendsStreamSubscription?.cancel();
      _friendsStreamSubscription =
          userRepository.getFriends().listen((friends) async {
        emit(
          FriendsLoaded(_toFriendVM(friends)),
        );
      });
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> joinGroup(String groupId) async {
    await conversationRepository.joinConversation(groupId);
    emit(GroupJoined(groupId));
  }

  Future<void> createGroup(
    String name,
    String description,
    bool isPrivate,
    List<String> participants,
  ) async {
    // validate
    if (name.isEmpty) {
      emit(GroupError('Group name cannot be empty'));
      return;
    }
    if (description.isEmpty) {
      emit(GroupError('Group description cannot be empty'));
      return;
    }
    if (participants.isEmpty) {
      emit(GroupError('Please select at least one friend'));
      return;
    }

    try {
      emit(GroupLoading());
      var group = await conversationRepository.createGroup(
        name,
        description,
        isPrivate,
        participants,
      );
      emit(GroupCreated(group));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  List<GroupVM> _toGroupVM(List<ConversationEntity> conversations) {
    return conversations
        .map(
          (e) => GroupVM(
            id: e.id,
            name: e.name,
            description: e.description,
          ),
        )
        .toList();
  }

  List<FriendVM> _toFriendVM(List<UserEntity> friends) {
    return friends
        .map(
          (e) => FriendVM(
            id: e.id,
            name: e.name,
            imageUrl: e.imageUrl,
          ),
        )
        .toList();
  }
}
