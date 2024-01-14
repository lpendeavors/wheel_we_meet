import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils.dart';
import '../chat/conversation.dart';
import 'bloc/group_cubit.dart';
import 'bloc/group_state.dart';
import 'create_group.dart';

class SearchGroupsScreen extends StatefulWidget {
  static const routeName = '/searchGroups';

  const SearchGroupsScreen({super.key});

  @override
  SearchGroupsScreenState createState() => SearchGroupsScreenState();
}

class SearchGroupsScreenState extends State<SearchGroupsScreen> {
  final _searchController = TextEditingController();
  bool showSearch = false;

  @override
  void initState() {
    super.initState();
    context.read<GroupCubit>().loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                if (showSearch) {
                  _searchController.clear();
                  context.read<GroupCubit>().searchGroups('');
                }
                showSearch = !showSearch;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (showSearch)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search groups',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => context
                          .read<GroupCubit>()
                          .searchGroups(_searchController.text.trim()),
                    ),
                  ),
                BlocBuilder<GroupCubit, GroupState>(
                  builder: (context, state) {
                    if (state is GroupJoined) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushReplacementNamed(
                          ConversationScreen.routeName,
                          arguments: {
                            'conversationId': state.groupId,
                          },
                        );
                      });
                      return Container();
                    } else if (state is GroupsLoaded) {
                      if (state.groups.isEmpty) {
                        return const Expanded(
                          child: Center(
                            child: Text('No groups found.'),
                          ),
                        );
                      }

                      return Expanded(
                        child: ListView.builder(
                          itemCount: state.groups.length,
                          itemBuilder: (context, index) {
                            final group = state.groups[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.blue[100],
                                child: Center(
                                  child: Text(
                                    group.name[0],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(first25Words(group.description)),
                              onTap: () => context.read<GroupCubit>().joinGroup(
                                    group.id,
                                  ),
                            );
                          },
                        ),
                      );
                    }
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                )
              ],
            ),
            Positioned(
              bottom: 32,
              right: 32,
              child: FloatingActionButton(
                heroTag: 'groupCreate',
                backgroundColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(
                    CreateGroupScreen.routeName,
                  )
                      .then((conversationId) {
                    if (conversationId != null) {
                      Navigator.of(context).pushReplacementNamed(
                        ConversationScreen.routeName,
                        arguments: {
                          'conversationId': conversationId,
                        },
                      );
                    }
                  });
                },
                tooltip: 'Create Group',
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
