import 'package:flutter/material.dart';

import 'bloc/conversation_enum.dart';

class ChatOptions extends StatelessWidget {
  const ChatOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.25,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              ListTile(
                leading: const Icon(Icons.location_pin),
                title: const Text('Share Location'),
                onTap: () => Navigator.of(context).pop(
                  ConversationOptionType.shareLocation,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('Mute Notifications'),
                onTap: () => Navigator.of(context).pop(
                  ConversationOptionType.muteNotifications,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.block,
                  color: Colors.red,
                ),
                title: const Text(
                  'Block User',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.of(context).pop(
                  ConversationOptionType.blockUser,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
