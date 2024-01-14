import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime? lastMessageTimestamp;
  final Map<String, bool> readStatus;
  final Map<String, bool> archiveStatus;
  final Map<String, bool> muteStatus;
  final bool isGroup;
  final String? photo;

  const ConversationEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.readStatus,
    required this.isGroup,
    required this.archiveStatus,
    required this.muteStatus,
    this.photo,
  });

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      participantIds: json['participantIds'] ?? [],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTimestamp: json['lastMessageTimestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['lastMessageTimestamp'].millisecondsSinceEpoch,
            )
          : null,
      readStatus: json['readStatus'] ?? {},
      isGroup: json['isGroup'] ?? false,
      archiveStatus: json['isArchived'] ?? {},
      muteStatus: json['isMuted'] ?? {},
      photo: json['photo'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        participantIds,
        lastMessage,
        lastMessageTimestamp,
        readStatus,
        isGroup,
        archiveStatus,
        muteStatus,
        photo,
      ];

  @override
  bool get stringify => true;
}
