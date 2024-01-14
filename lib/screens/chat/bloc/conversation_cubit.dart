import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/models.dart';
import '../../../repositories/conversation_repository.dart';
import 'conversation_vm.dart';
import 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final ConversationRepository conversationRepository;
  final String? friendId;
  final String? conversationId;

  StreamSubscription? _conversationSubscription;
  StreamSubscription? _conversationListSubscription;

  ConversationCubit({
    required this.friendId,
    required this.conversationId,
    required this.conversationRepository,
  }) : super(ConversationInitial());

  @override
  Future<void> close() {
    _conversationSubscription?.cancel();
    _conversationListSubscription?.cancel();
    return super.close();
  }

  void loadConversationList() async {
    try {
      emit(ConversationLoading());

      _conversationListSubscription?.cancel();
      _conversationListSubscription =
          conversationRepository.getConversations().listen(
        (result) {
          emit(ConversationListLoaded(
            _toConversationListVM(result.userId, result.conversations),
          ));
        },
        onError: (error) => emit(ConversationError(error.toString())),
      );
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void loadConversation() async {
    try {
      emit(ConversationLoading());

      _conversationSubscription?.cancel();
      _conversationSubscription = conversationRepository
          .getConversation(
        conversationId,
        friendId,
      )
          .listen(
        (result) {
          emit(
            ConversationLoaded(
              _toConversationVM(
                result.userId,
                result.conversation,
                result.users,
              ),
              _toMessageVM(
                result.messages,
                result.users,
                result.userId,
              ),
              _toUserVM(result.users),
            ),
          );
        },
        onError: (error) => emit(ConversationError(error.toString())),
      );
    } catch (e) {
      print(e.toString());
      emit(ConversationError(e.toString()));
    }
  }

  void archiveConversation(String conversationId) {
    try {
      conversationRepository.archiveConversation(conversationId);
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void unarchiveConversation(String conversationId) {
    try {
      conversationRepository.unarchiveConversation(conversationId);
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void muteConversation(String conversationId) {
    try {
      conversationRepository.muteConversation(conversationId);
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void unmuteConversation(String conversationId) {
    try {
      conversationRepository.unmuteConversation(conversationId);
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void markConversationAsRead(String conversationId) {
    try {
      conversationRepository.markConversationRead(conversationId);
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void sendMessage(String conversationId, String messageText) {
    try {
      conversationRepository.sendMessage(
        conversationId,
        messageText,
        null,
      );
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void editMessage(
      String conversationId, String messageId, String messageText) {
    try {
      conversationRepository.editMessage(
        conversationId,
        messageId,
        messageText,
        null,
      );
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void deleteMessage(String conversationId, String messageId) {
    try {
      conversationRepository.deleteMessage(conversationId, messageId);
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void likeMessage(String conversationId, String messageId) {
    try {
      conversationRepository.likeMessage(conversationId, messageId);
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  void unlikeMessage(String conversationId, String messageId) {
    try {
      conversationRepository.unlikeMessage(conversationId, messageId);
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  _toConversationListVM(
    String myId,
    List<ConversationEntity> conversations,
  ) {
    return conversations.map((conversation) {
      return ConversationListItemVM(
        id: conversation.id,
        name: conversation.name,
        photo: conversation.photo,
        isRead: conversation.readStatus[myId] ?? false,
        lastMessage: conversation.lastMessage,
        lastMessageTimestamp: conversation.lastMessageTimestamp,
      );
    }).toList();
  }

  _toConversationVM(
    String myId,
    ConversationEntity conversation,
    List<UserEntity> users,
  ) {
    final name = conversation.isGroup
        ? conversation.name
        : users.firstWhere((user) => user.id != myId).name;

    return ConversationVM(
      id: conversation.id,
      name: name,
      photo: conversation.photo ?? '',
      isGroup: conversation.isGroup,
      isRead: conversation.readStatus[myId] ?? false,
      isArchived: conversation.archiveStatus[myId] ?? false,
      isMuted: conversation.muteStatus[myId] ?? false,
      timestamp: conversation.lastMessageTimestamp,
    );
  }

  _toMessageVM(
    List<MessageEntity> messages,
    List<UserEntity> users,
    String myId,
  ) {
    return messages.map((message) {
      final sender = users.firstWhere(
        (user) => user.id == message.senderId,
      );
      return MessageVM(
        id: message.id,
        text: message.text,
        senderId: message.senderId,
        senderName: sender.name,
        senderPhoto: sender.imageUrl,
        timestamp: message.timestamp,
        isLiked: message.likeStatus[myId] ?? false,
        isRead: message.readStatus[myId] ?? false,
        isEdited: message.isEdited,
        isDeleted: message.isDeleted,
        isImage: message.imageUrl != null,
        imageUrl: message.imageUrl,
        isMine: message.senderId == myId,
      );
    }).toList();
  }

  _toUserVM(List<UserEntity> users) {
    return users.map((user) {
      return UserVM(
        id: user.id,
        name: user.name,
        photo: user.imageUrl,
      );
    }).toList();
  }
}
