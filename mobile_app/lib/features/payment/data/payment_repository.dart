import 'package:quickpass/api/client.dart';
import 'package:quickpass/features/cart/data/models/cart_item_model.dart';
import 'package:quickpass/features/payment/data/models/payment_model.dart';
import 'package:quickpass/utils/offline_sync.dart';
import 'package:uuid/uuid.dart';

class PaymentRepository {
  final ApiClient _client = ApiClient();
  final OfflineSyncService _offlineSync = OfflineSyncService();

  // Initiate M-PESA STK Push payment
  Future<PaymentModel> initiateMpesaPayment({
    required String phone,
    required double amount,
    required List<CartItemModel> cartItems,
  }) async {
    try {
      final paymentId = const Uuid().v4();
      final response = await _client.post('/payment/mpesa', {
        'phone': phone,
        'amount': amount,
        'paymentId': paymentId,
        'cartItems': cartItems.map((item) => item.toJson()).toList(),
      });

      return PaymentModel(
        id: paymentId,
        cartItems: cartItems,
        totalAmount: amount,
        method: PaymentMethod.mpesa,
        createdAt: DateTime.now(),
        transactionRef: response['transactionRef'],
      );
    } catch (e) {
      // Queue payment for offline sync
      final payment = PaymentModel(
        id: const Uuid().v4(),
        cartItems: cartItems,
        totalAmount: amount,
        method: PaymentMethod.mpesa,
        createdAt: DateTime.now(),
      );
      await _offlineSync.saveCartItemOffline(cartItems.first); // Simplified for demo
      throw Exception('M-PESA payment failed: $e');
    }
  }

  // Process card payment (placeholder for actual integration)
  Future<PaymentModel> processCardPayment({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required double amount,
    required List<CartItemModel> cartItems,
  }) async {
    try {
      final paymentId = const Uuid().v4();
      final response = await _client.post('/payment/card', {
        'cardNumber': cardNumber, // In production, encrypt sensitive data
        'expiry': expiry,
        'cvv': cvv,
        'amount': amount,
        'paymentId': paymentId,
        'cartItems': cartItems.map((item) => item.toJson()).toList(),
      });

      return PaymentModel(
        id: paymentId,
        cartItems: cartItems,
        totalAmount: amount,
        method: PaymentMethod.card,
        createdAt: DateTime.now(),
        transactionRef: response['transactionRef'],
      );
    } catch (e) {
      throw Exception('Card payment failed: $e');
    }
  }

  // Redeem loyalty points
  Future<PaymentModel> redeemLoyaltyPoints({
    required int points,
    required double amount,
    required List<CartItemModel> cartItems,
  }) async {
    try {
      final paymentId = const Uuid().v4();
      final response = await _client.post('/payment/loyalty', {
        'points': points,
        'amount': amount,
        'paymentId': paymentId,
        'cartItems': cartItems.map((item) => item.toJson()).toList(),
      });

      return PaymentModel(
        id: paymentId,
        cartItems: cartItems,
        totalAmount: amount,
        method: PaymentMethod.loyalty,
        createdAt: DateTime.now(),
        loyaltyPointsUsed: points,
        transactionRef: response['transactionRef'],
      );
    } catch (e) {
      throw Exception('Loyalty points redemption failed: $e');
    }
  }

  // Check payment status
  Future<PaymentStatus> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _client.get('/payment/status/$paymentId');
      return PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == response['status'],
      );
    } catch (e) {
      return PaymentStatus.pending; // Assume pending if check fails
    }
  }
}