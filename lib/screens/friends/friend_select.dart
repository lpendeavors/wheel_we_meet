import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../repositories/repositories.dart';
import 'bloc/friends_cubit.dart';
import 'bloc/friends_state.dart';

class FriendSelect extends StatelessWidget {
  final Function(String) onSelected;

  const FriendSelect({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FriendsCubit>(
      create: (context) => FriendsCubit(
        userRepository: GetIt.I.get<UserRepository>(),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.6,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          context.read<FriendsCubit>().loadFriends();

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<FriendsCubit, FriendsState>(
              builder: (context, state) {
                if (state is FriendsLoaded) {
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: state.friends.length,
                    itemBuilder: (context, index) {
                      final friend = state.friends[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: friend.imageUrl != null
                              ? NetworkImage(friend.imageUrl!)
                              : null,
                        ),
                        title: Text(friend.name),
                        onTap: () => onSelected(friend.id),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
