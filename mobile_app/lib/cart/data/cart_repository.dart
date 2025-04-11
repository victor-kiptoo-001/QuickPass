import 'package:quickpass/api/client.dart';
import 'package:quickpass/config/app_config.dart';
import 'package:quickpass/features/cart/data/models/cart_item_model.dart';
import 'package:quickpass/utils/offline_sync.dart';

class CartRepository {
  final ApiClient _client = ApiClient();
  final OfflineSyncService _offlineSync = OfflineSyncService();

  // Fetch item details by barcode from backend
  Future<CartItemModel> fetchItemByBarcode(String barcode) async {
    try {
      final response = await _client.get('/inventory/item/$barcode');
      return CartItemModel.fromJson(response);
    } catch (e) {
      // Check offline storage as fallback
      final offlineItems = await _offlineSync.getOfflineCartItems();
      final item = offlineItems.firstWhere(
        (item) => item.id == barcode,
        orElse: () => throw Exception('Item not found: $barcode'),
      );
      return item;
    }
  }

  // Add item to cart
  Future<List<CartItemModel>> addItem(CartItemModel item) async {
    try {
      final currentCart = await getCart();
      if (currentCart.length >= AppConfig.maxCartItems) {
        throw Exception('Cart limit reached (${AppConfig.maxCartItems} items)');
      }

      // Check if item already exists
      final existingItemIndex = currentCart.indexWhere((i) => i.id == item.id);
      List<CartItemModel> updatedCart;
      if (existingItemIndex != -1) {
        updatedCart = List.from(currentCart);
        updatedCart[existingItemIndex] = updatedCart[existingItemIndex].copyWith(
          quantity: updatedCart[existingItemIndex].quantity + item.quantity,
        );
      } else {
        updatedCart = [...currentCart, item.copyWith(isSynced: true)];
      }

      await _client.post('/cart/add', updatedCart.map((i) => i.toJson()).toList());
      return updatedCart;
    } catch (e) {
      // Save to offline storage
      await _offlineSync.saveCartItemOffline(item);
      final offlineCart = await _offlineSync.getOfflineCartItems();
      if (offlineCart.length > AppConfig.maxCartItems) {
        throw Exception('Offline cart limit reached');
      }
      return offlineCart;
    }
  }

  // Remove item from cart
  Future<List<CartItemModel>> removeItem(String itemId) async {
    try {
      final currentCart = await getCart();
      final updatedCart = currentCart.where((i) => i.id != itemId).toList();
      await _client.post('/cart/update', updatedCart.map((i) => i.toJson()).toList());
      return updatedCart;
    } catch (e) {
      // Update offline storage
      final offlineCart = await _offlineSync.getOfflineCartItems();
      final updatedOfflineCart = offlineCart.where((i) => i.id != itemId).toList();
      await _offlineSync.clearOfflineCart();
      for (var item in updatedOfflineCart) {
        await _offlineSync.saveCartItemOffline(item);
      }
      return updatedOfflineCart;
    }
  }

  // Get current cart
  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await _client.get('/cart');
      return (response as List).map((json) => CartItemModel.fromJson(json)).toList();
    } catch (e) {
      return await _offlineSync.getOfflineCartItems();
    }
  }

  // Sync offline cart with backend
  Future<void> syncCart() async {
    try {
      await _offlineSync.syncCart();
    } catch (e) {
      throw Exception('Cart sync failed: $e');
    }
  }
}