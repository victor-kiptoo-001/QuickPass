import 'package:json_annotation/json_annotation.dart';
import 'package:quickpass/features/cart/data/models/cart_item_model.dart';

part 'payment_model.g.dart';

enum PaymentMethod { mpesa, card, loyalty }
enum PaymentStatus { pending, completed, failed }

@JsonSerializable()
class PaymentModel {
  final String id; // Transaction ID
  final List<CartItemModel> cartItems; // Items being paid for
  final double totalAmount; // Total after discounts
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? transactionRef; // M-PESA or card transaction ID
  final int? loyaltyPointsUsed; // Points redeemed (if applicable)

  PaymentModel({
    required this.id,
    required this.cartItems,
    required this.totalAmount,
    required this.method,
    this.status = PaymentStatus.pending,
    required this.createdAt,
    this.transactionRef,
    this.loyaltyPointsUsed,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  // Create a copy with updated fields
  PaymentModel copyWith({
    String? id,
    List<CartItemModel>? cartItems,
    double? totalAmount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? createdAt,
    String? transactionRef,
    int? loyaltyPointsUsed,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      transactionRef: transactionRef ?? this.transactionRef,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
    );
  }
}