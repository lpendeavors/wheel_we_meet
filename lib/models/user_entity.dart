import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final List<String> friends;
  final DateTime? lastSeen;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.friends,
    this.imageUrl,
    this.lastSeen,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        imageUrl,
        friends,
        lastSeen,
      ];

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'],
      friends: List<String>.from(json['friends'] ?? []),
    );
  }
}
