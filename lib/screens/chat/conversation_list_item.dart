import 'package:flutter/material.dart';

import 'bloc/conversation_vm.dart';

class ConversationListItem extends StatelessWidget {
  final ConversationListItemVM conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    Key? key,
    required this.conversation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.lightBlue[100],
              backgroundImage: conversation.photo != null
                  ? NetworkImage(conversation.photo!)
                  : null,
              radius: 30,
              child: conversation.photo == null
                  ? Text(
                      conversation.name[0],
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
                    conversation.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    conversation.lastMessage,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              _formatTimestamp(
                conversation.lastMessageTimestamp,
              ),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            if (!conversation.isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    // Formatting logic for the timestamp
    return '';
  }
}
