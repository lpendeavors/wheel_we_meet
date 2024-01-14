import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/group_cubit.dart';
import 'bloc/group_state.dart';

class CreateGroupScreen extends StatefulWidget {
  static const routeName = '/createGroup';

  const CreateGroupScreen({super.key});

  @override
  CreateGroupScreenState createState() => CreateGroupScreenState();
}

class CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isPrivate = false;

  final selectedFriends = <String, bool>{};

  @override
  void initState() {
    super.initState();
    context.read<GroupCubit>().loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Group'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: InputBorder.none,
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: InputBorder.none,
                ),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Private Group'),
                value: isPrivate,
                onChanged: (bool value) {
                  setState(() {
                    isPrivate = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Add Friends to Group:'),
              BlocBuilder<GroupCubit, GroupState>(
                builder: (context, state) {
                  if (state is FriendsLoaded) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.friends.length,
                      itemBuilder: (context, index) {
                        final friend = state.friends[index];
                        return CheckboxListTile(
                          title: Text(friend.name),
                          value: selectedFriends[friend.id] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedFriends[friend.id] = value!;
                            });
                          },
                        );
                      },
                    );
                  } else if (state is GroupCreated) {
                    Navigator.of(context).pop(state.groupId);
                  } else if (state is GroupError) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity, // Stretch across the width
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final groupName = _groupNameController.text;
                    final description = _descriptionController.text;
                    final friendIds = selectedFriends.entries
                        .where((element) => element.value)
                        .map((e) => e.key)
                        .toList();
                    context.read<GroupCubit>().createGroup(
                          groupName,
                          description,
                          isPrivate,
                          friendIds,
                        );
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
