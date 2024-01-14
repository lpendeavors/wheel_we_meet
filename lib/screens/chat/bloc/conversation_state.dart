import 'conversation_vm.dart';

abstract class ConversationState {}

class ConversationListInitial extends ConversationState {}

class ConversationListLoading extends ConversationState {}

class ConversationListLoaded extends ConversationState {
  final List<ConversationListItemVM> conversations;

  ConversationListLoaded(this.conversations);
}

class ConversationListError extends ConversationState {
  final String message;
  ConversationListError(this.message);
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final ConversationVM conversation;
  final List<MessageVM> messages;
  final List<UserVM> participants;

  ConversationLoaded(this.conversation, this.messages, this.participants);
}

class ConversationError extends ConversationState {
  final String message;
  ConversationError(this.message);
}
