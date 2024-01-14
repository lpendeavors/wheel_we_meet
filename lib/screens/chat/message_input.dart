import 'package:flutter/material.dart';

class MessageInputField extends StatelessWidget {
  final Function(TextEditingController) onSend;

  const MessageInputField({
    super.key,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type a message",
                border: InputBorder.none,
                fillColor: Colors.transparent,
                filled: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (value) => onSend(controller),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onSend(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: const Text(
              'Send',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
