import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String phone;
  final String? deviceId; // For one-device login enforcement
  final String? token; // JWT token for session
  final DateTime? lastLogin;
  final bool isActive;

  UserModel({
    required this.id,
    required this.phone,
    this.deviceId,
    this.token,
    this.lastLogin,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Helper to create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? phone,
    String? deviceId,
    String? token,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      deviceId: deviceId ?? this.deviceId,
      token: token ?? this.token,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }
}