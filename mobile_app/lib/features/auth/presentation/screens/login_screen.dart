import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpass/features/auth/data/auth_repository.dart';
import 'package:quickpass/features/auth/presentation/screens/otp_screen.dart';
import 'package:quickpass/features/auth/presentation/widgets/auth_button.dart';
import 'package:quickpass/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;

  void _requestOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.requestOtp(_phoneController.text);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phone: _phoneController.text),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorLogin;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo or App Name
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: Offset(0, -0.2),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 600),
                  ),
                ],
                child: Text(
                  'QuickPass',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.welcomeBack,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 48),
              // Phone Input
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF1E88E5)),
                  errorText: _errorMessage,
                ),
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 16),
              ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
              const SizedBox(height: 24),
              // Auth Button
              AuthButton(
                text: AppLocalizations.of(context)!.sendOtp,
                isLoading: _isLoading,
                onPressed: _phoneController.text.isNotEmpty ? _requestOtp : null,
              ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
              const SizedBox(height: 16),
              // Support Contact
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement call/SMS support
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.contactSupport),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.needHelp,
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
    _phoneController.dispose();
    super.dispose();
  }
}