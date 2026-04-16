import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/vyoohm_screen.dart';
import 'screens/dharma_gpt_screen.dart';
import 'screens/sutra_summarizer_screen.dart';
import 'utils/app_colors.dart';

// Simple Language Provider for Pratilipi translation state
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = "English";
  String get currentLanguage => _currentLanguage;

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const ChanakyaApp(),
    ),
  );
}

class ChanakyaApp extends StatelessWidget {
  const ChanakyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chanakya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.obsidianBackground,
        primaryColor: AppColors.legalGold,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.legalGold,
          onPrimary: AppColors.surfaceDeep,
          secondary: AppColors.emeraldWin,
          surface: AppColors.surfaceElevated,
          onSurface: AppColors.textPrimary,
          background: AppColors.obsidianBackground,
          onBackground: AppColors.textPrimary,
          error: AppColors.crimsonLoss,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            color: AppColors.legalGold,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
          iconTheme: const IconThemeData(color: AppColors.legalGold),
        ),
        dividerColor: AppColors.slateAccent.withOpacity(0.3),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.legalGold,
            foregroundColor: AppColors.surfaceDeep,
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/vyoohm': (context) => const VyoohmScreen(),
        '/dharma-gpt': (context) => const DharmaGPTScreen(),
        '/sutra-summarizer': (context) => const SutraSummarizerScreen(),
      },
    );
  }
}
