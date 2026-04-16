import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../widgets/command_center_input.dart';
import '../widgets/glassmorphic_card.dart';
import '../main.dart'; // For LanguageProvider
import 'similar_cases_screen.dart';
import 'legal_trend_timeline_screen.dart';
import 'judicial_analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseController = TextEditingController();

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
            itemBuilder: (context) => [
              'English', 'Hindi', 'Marathi', 'Tamil', 'Telugu', 'Gujarati'
            ].map<PopupMenuEntry<String>>((lang) => PopupMenuItem<String>(
              value: lang,
              child: Text(lang),
            )).toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, -0.6),
                radius: 1.5,
                colors: [
                  Color(0xFF1E293B), // Slate Accent
                  AppColors.obsidianBackground,
                ],
              ),
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
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Sovereign\nIntelligence',
                        style: GoogleFonts.outfit(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeIn(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'Strategic judicial precision across decades of Indian legal precedents.',
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
                          hintText:
                              'Describe the case facts, acts involved, and key details...',
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
                                  'ANALYZE STRATEGIC PRECEDENTS',
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
                    
                    // --- Advanced Astra Tools ---
                    _SectionTitle(title: 'ASTRA INTELLIGENCE (AI)', icon: Icons.stars),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _AstraToolCard(
                            title: 'Dharma-GPT',
                            subtitle: 'Strategy Sim',
                            icon: Icons.psychology,
                            color: AppColors.legalGold,
                            onTap: () => Navigator.pushNamed(context, '/dharma-gpt'),
                          ),
                          const SizedBox(width: 16),
                          _AstraToolCard(
                            title: 'Vyoohm Graph',
                            subtitle: 'Precedent Map',
                            icon: Icons.hub,
                            color: AppColors.cyanTrend,
                            onTap: () => Navigator.pushNamed(context, '/vyoohm'),
                          ),
                          const SizedBox(width: 16),
                          _AstraToolCard(
                            title: 'Sutra Summary',
                            subtitle: 'Judgment TL;DR',
                            icon: Icons.auto_stories,
                            color: Colors.purpleAccent,
                            onTap: () => Navigator.pushNamed(context, '/sutra-summarizer'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Standard Analytics
                    _SectionTitle(title: 'JUDICIAL ENGINES', icon: Icons.bolt),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _AnalyticsToolCard(
                            title: 'Legal Trends',
                            subtitle: 'Win Ratios',
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
                            title: 'Judge Intel',
                            subtitle: 'Analytics',
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

class _AstraToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AstraToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: SizedBox(
        width: 160,
        height: 180,
        child: GlassmorphicCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
