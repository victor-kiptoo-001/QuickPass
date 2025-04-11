import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:quickpass/features/cart/data/models/cart_item_model.dart';
import 'package:quickpass/features/payment/data/models/payment_model.dart';
import 'package:quickpass/features/payment/data/payment_repository.dart';
import 'package:quickpass/features/payment/presentation/widgets/payment_option_widget.dart';
import 'package:quickpass/features/qr_exit/presentation/screens/qr_exit_screen.dart';
import 'package:quickpass/l10n/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _paymentRepository = PaymentRepository();
  PaymentMethod? _selectedMethod;
  bool _isLoading = false;
  String? _errorMessage;
  PaymentModel? _payment;
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _pointsController = TextEditingController();

  void _initiatePayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_selectedMethod == PaymentMethod.mpesa) {
        _payment = await _paymentRepository.initiateMpesaPayment(
          phone: _phoneController.text,
          amount: widget.totalPrice,
          cartItems: widget.cartItems,
        );
      } else if (_selectedMethod == PaymentMethod.card) {
        _payment = await _paymentRepository.processCardPayment(
          cardNumber: _cardNumberController.text,
          expiry: _expiryController.text,
          cvv: _cvvController.text,
          amount: widget.totalPrice,
          cartItems: widget.cartItems,
        );
      } else if (_selectedMethod == PaymentMethod.loyalty) {
        _payment = await _paymentRepository.redeemLoyaltyPoints(
          points: int.parse(_pointsController.text),
          amount: widget.totalPrice,
          cartItems: widget.cartItems,
        );
      }

      // Poll for payment status
      for (var i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 3));
        final status = await _paymentRepository.checkPaymentStatus(_payment!.id);
        if (status == PaymentStatus.completed) {
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.success);
          }
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QrExitScreen(paymentId: _payment!.id),
              ),
            );
          }
          return;
        } else if (status == PaymentStatus.failed) {
          throw Exception('Payment failed');
        }
      }
      throw Exception('Payment timed out');
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorPayment(e.toString());
      });
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.error);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.payment),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart Summary
              Text(
                AppLocalizations.of(context)!.cartSummary,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ...widget.cartItems.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} (x${item.quantity})',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Text(
                                  'KSH ${item.totalPrice.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.total,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'KSH ${widget.totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF1E88E5),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 300),
                  ),
              const SizedBox(height: 24),
              // Payment Options
              Text(
                AppLocalizations.of(context)!.selectPaymentMethod,
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
              const SizedBox(height: 16),
              PaymentOptionWidget(
                method: PaymentMethod.mpesa,
                icon: Icons.phone_android,
                title: AppLocalizations.of(context)!.mpesa,
                isSelected: _selectedMethod == PaymentMethod.mpesa,
                onTap: () => setState(() => _selectedMethod = PaymentMethod.mpesa),
              ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
              if (_selectedMethod == PaymentMethod.mpesa)
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
              PaymentOptionWidget(
                method: PaymentMethod.card,
                icon: Icons.credit_card,
                title: AppLocalizations.of(context)!.card,
                isSelected: _selectedMethod == PaymentMethod.card,
                onTap: () => setState(() => _selectedMethod = PaymentMethod.card),
              ).animate().fadeIn(delay: const Duration(milliseconds: 700)),
              if (_selectedMethod == PaymentMethod.card)
                Column(
                  children: [
                    TextField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.cardNumber,
                        prefixIcon: const Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.expiry,
                            ),
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _cvvController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.cvv,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
              PaymentOptionWidget(
                method: PaymentMethod.loyalty,
                icon: Icons.star,
                title: AppLocalizations.of(context)!.loyaltyPoints,
                isSelected: _selectedMethod == PaymentMethod.loyalty,
                onTap: () => setState(() => _selectedMethod = PaymentMethod.loyalty),
              ).animate().fadeIn(delay: const Duration(milliseconds: 900)),
              if (_selectedMethod == PaymentMethod.loyalty)
                TextField(
                  controller: _pointsController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.pointsToRedeem,
                    prefixIcon: const Icon(Icons.star),
                  ),
                  keyboardType: TextInputType.number,
                ).animate().fadeIn(delay: const Duration(milliseconds: 1000)),
              const SizedBox(height: 24),
              // Pay Button
              if (_selectedMethod != null)
                ElevatedButton(
                  onPressed: _isLoading ? null : _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.payNow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ).animate().scale(delay: const Duration(milliseconds: 1100)),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _pointsController.dispose();
    super.dispose();
  }
}