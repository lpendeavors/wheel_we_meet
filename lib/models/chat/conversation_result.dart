import '../user_entity.dart';
import 'conversation_entity.dart';
import 'message_entity.dart';

class ConversationResult {
  final String userId;
  final ConversationEntity conversation;
  final List<MessageEntity> messages;
  final List<UserEntity> users;

  ConversationResult(
    this.userId,
    this.conversation,
    this.messages,
    this.users,
  );
}

class ConversationListResult {
  final String userId;
  final List<ConversationEntity> conversations;

  ConversationListResult(
    this.userId,
    this.conversations,
  );
}
