import 'package:json_annotation/json_annotation.dart';

part 'loyalty_model.g.dart';

enum LoyaltyTransactionType { earned, redeemed }

@JsonSerializable()
class LoyaltyTransaction {
  final String id;
  final LoyaltyTransactionType type;
  final int points;
  final DateTime date;
  final String? transactionRef; // Links to payment or earning event

  LoyaltyTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.date,
    this.transactionRef,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyTransactionToJson(this);
}

@JsonSerializable()
class LoyaltyModel {
  final String userId;
  final int balance; // Current points balance
  final List<LoyaltyTransaction> history;

  LoyaltyModel({
    required this.userId,
    required this.balance,
    this.history = const [],
  });

  factory LoyaltyModel.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyModelToJson(this);

  // Calculate total points earned
  int get totalEarned =>
      history.where((t) => t.type == LoyaltyTransactionType.earned).fold(
            0,
            (sum, t) => sum + t.points,
          );

  // Calculate total points redeemed
  int get totalRedeemed =>
      history.where((t) => t.type == LoyaltyTransactionType.redeemed).fold(
            0,
            (sum, t) => sum + t.points,
          );

  // Create a copy with updated fields
  LoyaltyModel copyWith({
    String? userId,
    int? balance,
    List<LoyaltyTransaction>? history,
  }) {
    return LoyaltyModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      history: history ?? this.history,
    );
  }
}