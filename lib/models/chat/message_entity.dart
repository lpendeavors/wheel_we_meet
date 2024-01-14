import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final Map<String, bool> likeStatus;
  final Map<String, bool> readStatus;
  final bool isEdited;
  final bool isDeleted;
  final String? imageUrl;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.likeStatus,
    required this.readStatus,
    required this.isEdited,
    required this.isDeleted,
    required this.imageUrl,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as Timestamp).millisecondsSinceEpoch,
      ),
      likeStatus: json['likeStatus'] ?? {},
      readStatus: json['readStatus'] ?? {},
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        text,
        timestamp,
        likeStatus,
        readStatus,
        isEdited,
        isDeleted,
        imageUrl,
      ];

  @override
  bool get stringify => true;
}
