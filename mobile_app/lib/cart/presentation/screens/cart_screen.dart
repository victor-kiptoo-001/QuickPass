import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:quickpass/config/app_config.dart';
import 'package:quickpass/features/cart/data/cart_repository.dart';
import 'package:quickpass/features/cart/data/models/cart_item_model.dart';
import 'package:quickpass/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:quickpass/features/payment/presentation/screens/payment_screen.dart';
import 'package:quickpass/l10n/app_localizations.dart';
import 'package:quickpass/utils/barcode_scanner.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartRepository = CartRepository();
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _cartRepository.syncCart(); // Attempt to sync offline cart
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      _cartItems = await _cartRepository.getCart();
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorLoadingCart;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanItem() async {
    final barcode = await BarcodeScanner.scan(context);
    if (barcode == null) return;

    setState(() => _isLoading = true);
    try {
      final item = await _cartRepository.fetchItemByBarcode(barcode);
      _cartItems = await _cartRepository.addItem(item);
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.success); // Haptic feedback
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.itemAdded(item.name)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeItem(String itemId) async {
    setState(() => _isLoading = true);
    try {
      _cartItems = await _cartRepository.removeItem(itemId);
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.light);
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorRemovingItem;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cart),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCart,
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                AppLocalizations.of(context)!.yourCart,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              // Cart Items
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _cartItems.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)!.emptyCart,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) => _removeItem(item.id),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: CartItemWidget(
                                  item: item,
                                  onQuantityChanged: (newQuantity) async {
                                    setState(() => _isLoading = true);
                                    try {
                                      _cartItems = await _cartRepository.addItem(
                                        item.copyWith(
                                          quantity: newQuantity,
                                          isSynced: true,
                                        ),
                                      );
                                    } catch (e) {
                                      setState(() {
                                        _errorMessage = AppLocalizations.of(context)!
                                            .errorUpdatingQuantity;
                                      });
                                    } finally {
                                      setState(() => _isLoading = false);
                                    }
                                  },
                                ).animate().slideX(
                                      delay: Duration(milliseconds: 100 * index),
                                      duration: const Duration(milliseconds: 300),
                                    ),
                              );
                            },
                          ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              // Total and Checkout
              if (_cartItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.total,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'KSH ${_totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF1E88E5),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(
                                      cartItems: _cartItems,
                                      totalPrice: _totalPrice,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(AppLocalizations.of(context)!.proceedToPayment),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _scanItem,
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.qr_code_scanner),
      ).animate().scale(delay: const Duration(milliseconds: 600)),
    );
  }
}