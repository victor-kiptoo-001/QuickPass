import 'package:json_annotation/json_annotation.dart';

part 'qr_model.g.dart';

@JsonSerializable()
class QrModel {
  final String id; // QR code ID (tied to payment ID)
  final String transactionId; // Payment transaction ID
  final String token; // Single-use token for verification
  final DateTime createdAt;
  final DateTime expiresAt;
  final String receiptUrl; // URL for digital receipt
  final bool isUsed; // Tracks if QR code has been scanned

  QrModel({
    required this.id,
    required this.transactionId,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
    required this.receiptUrl,
    this.isUsed = false,
  });

  factory QrModel.fromJson(Map<String, dynamic> json) => _$QrModelFromJson(json);

  Map<String, dynamic> toJson() => _$QrModelToJson(this);

  // Check if QR code is still valid
  bool get isValid => DateTime.now().isBefore(expiresAt) && !isUsed;

  // Create a copy with updated fields
  QrModel copyWith({
    String? id,
    String? transactionId,
    String? token,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? receiptUrl,
    bool? isUsed,
  }) {
    return QrModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}