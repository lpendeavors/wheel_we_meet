class ConversationListItemVM {
  final String id;
  final String name;
  final String? photo;
  final bool isRead;
  final String lastMessage;
  final DateTime? lastMessageTimestamp;

  ConversationListItemVM({
    required this.id,
    required this.name,
    required this.photo,
    required this.isRead,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });
}

class ConversationVM {
  final String id;
  final String name;
  final String photo;
  final bool isGroup;
  final bool isRead;
  final bool isArchived;
  final bool isMuted;
  final DateTime? timestamp;

  ConversationVM({
    required this.id,
    required this.name,
    required this.photo,
    required this.isGroup,
    required this.isRead,
    required this.isArchived,
    required this.isMuted,
    required this.timestamp,
  });
}

class MessageVM {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String? senderPhoto;
  final DateTime timestamp;
  final bool isLiked;
  final bool isRead;
  final bool isEdited;
  final bool isDeleted;
  final bool isImage;
  final String? imageUrl;
  final bool isMine;

  MessageVM({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isLiked,
    required this.isRead,
    required this.isEdited,
    required this.isDeleted,
    required this.isImage,
    required this.isMine,
    required this.imageUrl,
    required this.senderPhoto,
  });
}

class UserVM {
  final String id;
  final String name;
  final String? photo;

  UserVM({
    required this.id,
    required this.name,
    required this.photo,
  });
}
