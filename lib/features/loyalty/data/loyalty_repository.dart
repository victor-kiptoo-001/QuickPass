import 'package:quickpass/api/client.dart';
import 'package:quickpass/features/loyalty/data/models/loyalty_model.dart';
import 'package:uuid/uuid.dart';

class LoyaltyRepository {
  final ApiClient _client = ApiClient();

  // Fetch user's loyalty points and history
  Future<LoyaltyModel> fetchLoyaltyData(String userId) async {
    try {
      final response = await _client.get('/loyalty/$userId');
      return LoyaltyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch loyalty data: $e');
    }
  }

  // Redeem loyalty points (called from payment feature)
  Future<LoyaltyModel> redeemPoints({
    required String userId,
    required int points,
    required String paymentId,
  }) async {
    try {
      final response = await _client.post('/loyalty/redeem', {
        'userId': userId,
        'points': points,
        'paymentId': paymentId,
      });
      return LoyaltyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to redeem points: $e');
    }
  }

  // Add points (called server-side after payment, exposed here for testing)
  Future<LoyaltyModel> addPoints({
    required String userId,
    required int points,
    required String transactionRef,
  }) async {
    try {
      final response = await _client.post('/loyalty/add', {
        'userId': userId,
        'points': points,
        'transactionRef': transactionRef,
      });
      return LoyaltyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add points: $e');
    }
  }
}