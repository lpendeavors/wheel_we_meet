import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final String userId;
  final bool enableNotifications;
  final String theme;
  final bool locationSharingEnabled;

  const SettingsEntity({
    required this.userId,
    this.enableNotifications = true,
    this.theme = 'light',
    this.locationSharingEnabled = false,
  });

  @override
  List<Object?> get props => [
        userId,
        enableNotifications,
        theme,
        locationSharingEnabled,
      ];

  factory SettingsEntity.fromJson(Map<String, dynamic> json) {
    return SettingsEntity(
      userId: json['userId'],
      enableNotifications: json['enableNotifications'],
      theme: json['theme'],
      locationSharingEnabled: json['locationSharingEnabled'],
    );
  }
}
