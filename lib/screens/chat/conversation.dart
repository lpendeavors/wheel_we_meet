import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/conversation_cubit.dart';
import 'bloc/conversation_enum.dart';
import 'bloc/conversation_state.dart';
import 'conversation_options.dart';
import 'message_input.dart';
import 'message_item.dart';

class ConversationScreen extends StatefulWidget {
  static const routeName = '/conversation';

  const ConversationScreen({super.key});

  @override
  ConversationScreenState createState() => ConversationScreenState();
}

class ConversationScreenState extends State<ConversationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationCubit>().loadConversation();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationCubit, ConversationState>(
      builder: (context, state) {
        if (state is ConversationLoaded && !state.conversation.isRead) {
          context
              .read<ConversationCubit>()
              .markConversationAsRead(state.conversation.id);
        }

        if (state is ConversationLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is ConversationLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state.conversation.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () async {
                    final option = await _showConversationOptions(context);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildMessageList(state),
                  const SizedBox(height: 8),
                  _buildMessageInputField(state),
                ],
              ),
            ),
          );
        }
        if (state is ConversationError) {
          return Scaffold(
            body: Center(
              child: Text(state.message),
            ),
          );
        }
        return const Scaffold();
      },
    );
  }

  Widget _buildMessageList(ConversationLoaded state) {
    return Expanded(
      child: ListView.separated(
        reverse: true,
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          return MessageItem(message: message);
        },
        separatorBuilder: (context, index) => const SizedBox(
          height: 4,
        ),
      ),
    );
  }

  Widget _buildMessageInputField(ConversationLoaded state) {
    return MessageInputField(onSend: (controller) {
      if (controller.value.text.trim().isNotEmpty) {
        context.read<ConversationCubit>().sendMessage(
              state.conversation.id,
              controller.value.text.trim(),
            );
        controller.clear();
      }
    });
  }

  Future<ConversationOptionType?> _showConversationOptions(
      BuildContext context) async {
    return showModalBottomSheet<ConversationOptionType>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const ChatOptions();
      },
    );
  }
}
