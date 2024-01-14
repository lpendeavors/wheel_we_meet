import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_button.dart';
import 'bloc/conversation_cubit.dart';
import 'bloc/conversation_state.dart';
import 'conversation.dart';
import 'conversation_list_item.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({super.key});

  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final conversationsBloc = context.read<ConversationCubit>();
    conversationsBloc.loadConversationList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: BlocBuilder<ConversationCubit, ConversationState>(
        builder: (context, state) {
          if (state is ConversationListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConversationListLoaded) {
            return SafeArea(
              child: Stack(
                children: [
                  if (state.conversations.isEmpty) ...[
                    const Center(child: Text('No conversations')),
                  ],
                  ListView.builder(
                    itemCount: state.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = state.conversations[index];
                      return ConversationListItem(
                        conversation: conversation,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            ConversationScreen.routeName,
                            arguments: {
                              'friendId': null,
                              'conversationId': conversation.id,
                            },
                          );
                        },
                      );
                    },
                  ),
                  const Positioned(
                    bottom: 32,
                    right: 32,
                    child: AddButton(),
                  ),
                  // Positioned(
                  //   bottom: 16,
                  //   right: 16,
                  //   child: FloatingActionButton(
                  //     backgroundColor: Colors.blue,
                  //     onPressed: () {
                  //       Navigator.of(context).pushNamed(
                  //         ConversationScreen.routeName,
                  //         arguments: {
                  //           'friendId': null,
                  //           'conversationId': null,
                  //         },
                  //       );
                  //     },
                  //     child: const Icon(
                  //       Icons.add_comment,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          } else if (state is ConversationListError) {
            return const Center(
              child: Text('Failed to load conversations'),
            );
          }
          return Container();
        },
      ),
    );
  }
}
