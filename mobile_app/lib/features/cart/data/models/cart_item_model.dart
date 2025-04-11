import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItemModel {
  final String id; // Unique item ID (e.g., barcode)
  final String name; // Product name
  final double price; // Base price per unit
  final int quantity; // Number of units
  final double? discount; // Discount percentage (e.g., 0.1 for 10%)
  final String? imageUrl; // Optional product image
  final bool isSynced; // Tracks if item is synced with backend

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.discount,
    this.imageUrl,
    this.isSynced = false,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  // Calculate total price for this item (including discount)
  double get totalPrice {
    final basePrice = price * quantity;
    if (discount != null && discount! > 0) {
      return basePrice * (1 - discount!);
    }
    return basePrice;
  }

  // Create a copy with updated fields
  CartItemModel copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    double? discount,
    String? imageUrl,
    bool? isSynced,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      imageUrl: imageUrl ?? this.imageUrl,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}