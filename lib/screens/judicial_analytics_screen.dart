import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/glassmorphic_card.dart';

class JudicialAnalyticsScreen extends StatefulWidget {
  final String? judgeName;

  const JudicialAnalyticsScreen({super.key, this.judgeName});

  @override
  State<JudicialAnalyticsScreen> createState() => _JudicialAnalyticsScreenState();
}

class _JudicialAnalyticsScreenState extends State<JudicialAnalyticsScreen> {
  late Future<JudgeAnalyticsModel> _analyticsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _apiService.getJudgeAnalytics(widget.judgeName ?? 'Unknown Judge');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        title: Text(
          'JUDICIAL INTELLIGENCE',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.legalGold,
          ),
        ),
      ),
      body: FutureBuilder<JudgeAnalyticsModel>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.legalGold));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.crimsonLoss),
                    const SizedBox(height: 16),
                    Text('Analysis Error: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judge Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.legalGold, width: 2),
                            gradient: LinearGradient(
                              colors: [AppColors.legalGold.withOpacity(0.2), Colors.transparent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.person, size: 60, color: AppColors.legalGold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          data.judgeName.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          'PRESIDING JUSTICE',
                          style: TextStyle(
                            color: AppColors.legalGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // KPI Dashboard
                  Row(
                    children: [
                      Expanded(
                        child: _KPIBlock(
                          label: 'LIFETIME PRECEDENTS',
                          value: data.totalCases.toString(),
                          icon: Icons.gavel,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _KPIBlock(
                          label: 'WIN PROBABILITY',
                          value: '${data.winRate.toStringAsFixed(1)}%',
                          icon: Icons.trending_up,
                          color: data.winRate >= 50.0 ? AppColors.emeraldWin : AppColors.crimsonLoss,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _SectionHeader(title: 'FREQUENTLY CITED ACTS', icon: Icons.history),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: data.frequentLaws.map((law) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.legalGold.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.legalGold.withOpacity(0.2)),
                      ),
                      child: Text(
                        law,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )).toList(),
                  ),

                  _SectionHeader(title: 'PREDICTIVE BENCHMARKS (WIN %)', icon: Icons.analytics),
                  const SizedBox(height: 16),
                  if (data.predictiveBenchmarks.isEmpty)
                    const Text('Insufficient data for predictive benchmarking.', style: TextStyle(color: AppColors.textMuted, fontSize: 12))
                  else
                    Column(
                      children: data.predictiveBenchmarks.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            SizedBox(width: 80, child: Text(entry.key, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13))),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: entry.value / 100.0,
                                  backgroundColor: AppColors.surfaceElevated,
                                  color: entry.value >= 50.0 ? AppColors.emeraldWin : AppColors.crimsonLoss,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('${entry.value}%', style: TextStyle(color: entry.value >= 50.0 ? AppColors.emeraldWin : AppColors.crimsonLoss, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      )).toList(),
                    ),

                  const SizedBox(height: 32),
                  _SectionHeader(title: 'JUDICIAL STANCE', icon: Icons.psychology),
                  const SizedBox(height: 16),
                  GlassmorphicCard(
                    child: Text(
                      'This presiding justice shows a consistent ${data.winRate >= 50.0 ? "favorable" : "critical"} pattern regarding cited Acts. Average case duration is recorded at ${data.avgDurationDays} days, indicating a ${data.avgDurationDays < 365 ? "rapid" : "meticulous"} disposal speed.',
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.legalGold, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _KPIBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _KPIBlock({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? AppColors.legalGold, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}


