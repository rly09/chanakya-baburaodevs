import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../widgets/command_center_input.dart';
import '../widgets/glassmorphic_card.dart';
import 'package:chanakya/providers/language_provider.dart';
import 'similar_cases_screen.dart';
import 'legal_trend_timeline_screen.dart';
import 'judicial_analytics_screen.dart';
import 'petition_stress_test_screen.dart';
import '../widgets/dharma_gpt_fab.dart';
import '../widgets/continuous_marquee.dart';
import '../widgets/legal_codex_book.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<String> _trendingCases = [];

  @override
  void initState() {
    super.initState();
    _loadTrendingCases();
  }

  Future<void> _loadTrendingCases() async {
    final cases = await _apiService.fetchTrendingCases();
    if (mounted) {
      setState(() {
        _trendingCases = cases;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SimilarCasesScreen(query: _caseController.text),
        ),
      );
    }
  }

  @override
  void dispose() {
    _caseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      floatingActionButton: const DharmaGptFab(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'CHANAKYA',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
            fontSize: 24,
            color: AppColors.legalGold,
          ),
        ),
        actions: [
          // Pratilipi: Language Toggle
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate, color: AppColors.legalGold),
            onSelected: (lang) => languageProvider.setLanguage(lang),
            itemBuilder: (context) =>
                ['English', 'Hindi', 'Marathi', 'Tamil', 'Telugu', 'Gujarati']
                    .map<PopupMenuEntry<String>>(
                      (lang) =>
                          PopupMenuItem<String>(value: lang, child: Text(lang)),
                    )
                    .toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_trendingCases.isNotEmpty)
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: ContinuousMarquee(
                            items: _trendingCases,
                            textStyle: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    FadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        languageProvider.translate(
                          'Strategic judicial precision across decades of Indian legal precedents.',
                        ),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Command Center
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CommandCenterInput(
                          controller: _caseController,
                          hintText: languageProvider.translate(
                            'Describe the case facts, acts involved, and key details...',
                          ),
                          onSubmitted: _submit,
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  languageProvider.translate(
                                    'ANALYZE STRATEGIC PRECEDENTS',
                                  ),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 64),

                    // Standard Analytics
                    _SectionTitle(
                      title: languageProvider.translate('JUDICIAL ENGINES'),
                      icon: Icons.bolt,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _AnalyticsToolCard(
                            title: languageProvider.translate('Legal Trends'),
                            subtitle: languageProvider.translate('Win Ratios'),
                            icon: Icons.timeline,
                            color: AppColors.cyanTrend,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LegalTrendTimelineScreen(
                                        initialAct: 'IPC',
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _AnalyticsToolCard(
                            title: languageProvider.translate('Judge Intel'),
                            subtitle: languageProvider.translate('Analytics'),
                            icon: Icons.gavel,
                            color: AppColors.legalGold,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const JudicialAnalyticsScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Petition Stress-Test — Full-width hero card
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PetitionStressTestScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.biotech,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Agni Pariksha',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Trial by Fire — अग्नि परीक्षा',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 10,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'AI Red-Teams your petition against 50K precedents before you file.',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white38,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Vidhi Shastra Section
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            title: languageProvider.translate('VIDHI SHASTRA'),
                            icon: Icons.book,
                          ),
                          const SizedBox(height: 20),
                          const LegalCodexBook(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.legalGold.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        Icon(icon, color: AppColors.legalGold, size: 16),
      ],
    );
  }
}

class _AnalyticsToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnalyticsToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
