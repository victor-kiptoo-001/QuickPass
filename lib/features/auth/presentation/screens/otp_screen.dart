import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:quickpass/features/auth/data/auth_repository.dart';
import 'package:quickpass/features/auth/presentation/widgets/auth_button.dart';
import 'package:quickpass/l10n/app_localizations.dart';
import 'package:quickpass/features/cart/presentation/screens/cart_screen.dart'; // Placeholder for next screen

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authRepository.verifyOtp(widget.phone, _otpController.text);
      if (mounted) {
        // Navigate to cart screen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorOtp;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.requestOtp(widget.phone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.otpResent),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorResendOtp;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.verifyOtp),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.enterOtp,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.otpSentTo(widget.phone),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              // OTP Input
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                onChanged: (value) => setState(() {}),
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey[200],
                  selectedFillColor: const Color(0xFFBBDEFB),
                  activeColor: const Color(0xFF1E88E5),
                  inactiveColor: Colors.grey[400],
                  selectedColor: const Color(0xFF1E88E5),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                errorTextSpace: 24,
                errorTextDirection: TextDirection.l-paid,
                errorText: _errorMessage,
              ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
              const SizedBox(height: 24),
              // Verify Button
              AuthButton(
                text: AppLocalizations.of(context)!.verify,
                isLoading: _isLoading,
                onPressed: _otpController.text.length == 6 ? _verifyOtp : null,
              ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
              const SizedBox(height: 16),
              // Resend OTP
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  child: Text(
                    AppLocalizations.of(context)!.resendOtp,
                    style: const TextStyle(color: Color(0xFF1E88E5)),
                  ),
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
    _otpController.dispose();
    super.dispose();
  }
}