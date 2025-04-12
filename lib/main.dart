import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpass/config/app_config.dart';
import 'package:quickpass/features/auth/presentation/screens/login_screen.dart';
import 'package:quickpass/l10n/app_localizations.dart';
import 'package:quickpass/utils/offline_sync.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize offline sync service
  await OfflineSyncService().init();
  runApp(const QuickPassApp());
}

class QuickPassApp extends StatelessWidget {
  const QuickPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickPass',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E88E5), // Vibrant blue
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            shadowColor: Colors.black26,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('sw', ''), // Swahili
      ],
      home: Animate(
        effects: const [
          FadeEffect(duration: Duration(milliseconds: 800)),
          SlideEffect(
            begin: Offset(0, 0.2),
            end: Offset.zero,
            duration: Duration(milliseconds: 800),
          ),
        ],
        child: const LoginScreen(),
      ),
    );
  }
}