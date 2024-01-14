import 'package:flutter/material.dart';

import '../../utils.dart';
import 'bloc/conversation_vm.dart';

class MessageItem extends StatelessWidget {
  final MessageVM message;

  const MessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: isMine ? const Radius.circular(12) : Radius.zero,
      bottomRight: isMine ? Radius.zero : const Radius.circular(12),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.70,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue : Colors.grey[300],
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMine ? Colors.white : Colors.black87,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formatTimestamp(message.timestamp),
                style: TextStyle(
                  color: isMine ? Colors.grey[300] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
