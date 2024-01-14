import 'package:flutter/material.dart';

class GroupMembersScreen extends StatelessWidget {
  static const routeName = '/groupMembers';

  const GroupMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Members'),
      ),
      body: const Center(
        child: Text('Group Members'),
      ),
    );
  }
}
