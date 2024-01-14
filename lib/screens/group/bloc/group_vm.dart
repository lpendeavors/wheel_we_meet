import 'package:equatable/equatable.dart';

class GroupVM extends Equatable {
  final String id;
  final String name;
  final String description;

  const GroupVM({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
      ];

  @override
  bool get stringify => true;
}

class FriendVM extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;

  const FriendVM({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
      ];

  @override
  bool get stringify => true;
}
