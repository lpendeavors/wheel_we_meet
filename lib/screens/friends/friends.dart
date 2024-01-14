import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chat/conversation.dart';
import 'add_friend.dart';
import 'bloc/friends_cubit.dart';
import 'bloc/friends_enum.dart';
import 'bloc/friends_state.dart';
import 'friend_options.dart';

class FriendsScreen extends StatefulWidget {
  static const String routeName = '/friends';

  const FriendsScreen({super.key});

  @override
  FriendsSreenState createState() => FriendsSreenState();
}

class FriendsSreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FriendsCubit>().loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FriendsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: BlocBuilder<FriendsCubit, FriendsState>(
        builder: (context, state) {
          if (state is FriendsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FriendsLoaded) {
            return SafeArea(
              child: Stack(
                children: [
                  if (state.requests.isEmpty && state.friends.isEmpty)
                    const Center(
                      child: Text(
                        'You have no friends yet. Add some!',
                      ),
                    ),
                  if (state.requests.isNotEmpty)
                    _buildFriendRequestSection(state, bloc),
                  if (state.friends.isNotEmpty)
                    _buildFriendSection(state, bloc),
                  Positioned(
                    bottom: 32,
                    right: 32,
                    child: FloatingActionButton(
                      onPressed: () async {
                        final email = await _showAddFriendDialog(context);
                        if (email != null) bloc.addFriend(email);
                      },
                      backgroundColor: Colors.blue,
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is FriendsError) {
            return Center(
              child: Text(state.message),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildFriendRequestSection(
    FriendsLoaded state,
    FriendsCubit bloc,
  ) {
    return ListView.builder(
      itemCount: state.requests.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.lightBlue[100],
                backgroundImage: state.requests[index].imageUrl != null
                    ? NetworkImage(state.requests[index].imageUrl!)
                    : null,
                radius: 30,
                child: state.requests[index].imageUrl == null
                    ? Text(
                        state.requests[index].name[0],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.requests[index].name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      bloc.acceptFriendRequest(
                        state.requests[index].id,
                      );
                    },
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 35,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      bloc.cancelFriendRequest(
                        state.requests[index].id,
                      );
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 35,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFriendSection(
    FriendsLoaded state,
    FriendsCubit bloc,
  ) {
    return ListView.builder(
      itemCount: state.friends.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          _showFriendOptions(
            state.friends[index].id,
          ).then(
            (option) {
              if (option == FriendOptionType.delete) {
                bloc.deleteFriend(state.friends[index].id);
              }

              if (option == FriendOptionType.message) {
                Navigator.of(context).pushNamed(
                  ConversationScreen.routeName,
                  arguments: {
                    'friendId': state.friends[index].id,
                  },
                );
              }

              if (option == FriendOptionType.toggleNotifications) {
                // TODO: Implement toggle notifications
              }
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.lightBlue[100],
                backgroundImage: state.friends[index].imageUrl != null
                    ? NetworkImage(state.friends[index].imageUrl!)
                    : null,
                radius: 30,
                child: state.friends[index].imageUrl == null
                    ? Text(
                        state.friends[index].name[0],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.friends[index].name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Active 2 hrs ago',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showAddFriendDialog(BuildContext context) async {
    final email = await showDialog<String?>(
      context: context,
      builder: (context) => const AddFriend(),
    );
    return email;
  }

  Future<FriendOptionType?> _showFriendOptions(
    String friendId,
  ) {
    return showModalBottomSheet<FriendOptionType>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const FriendOptions();
      },
    );
  }
}
