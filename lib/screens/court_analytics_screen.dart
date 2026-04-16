import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/glassmorphic_card.dart';

class CourtAnalyticsScreen extends StatefulWidget {
  final String? courtName;

  const CourtAnalyticsScreen({super.key, this.courtName});

  @override
  State<CourtAnalyticsScreen> createState() => _CourtAnalyticsScreenState();
}

class _CourtAnalyticsScreenState extends State<CourtAnalyticsScreen> {
  late Future<CourtAnalyticsModel> _analyticsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _apiService.getCourtAnalytics(widget.courtName ?? 'Unknown Court');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        title: Text(
          'COURT INTELLIGENCE',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.legalGold,
          ),
        ),
      ),
      body: FutureBuilder<CourtAnalyticsModel>(
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
                  // Court Header
                  _SectionHeader(title: 'PREMISES DATA', icon: Icons.account_balance),
                  const SizedBox(height: 16),
                  Text(
                    data.courtName.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // KPI Row
                  Row(
                    children: [
                      Expanded(
                        child: _KPIBlock(
                          label: 'TOTAL VOL.',
                          value: data.totalCases.toString(),
                          icon: Icons.analytics,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _KPIBlock(
                          label: 'DISPOSAL SPEED',
                          value: data.disposalSpeed,
                          icon: Icons.speed,
                          color: data.disposalSpeed.toLowerCase().contains('high') ? AppColors.emeraldWin : AppColors.legalGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Distribution Box
                  _SectionHeader(title: 'ACT DISTRIBUTION', icon: Icons.pie_chart),
                  const SizedBox(height: 16),
                  GlassmorphicCard(
                    child: Column(
                      children: data.actDistribution.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('${(entry.value).toStringAsFixed(1)}%', style: const TextStyle(color: AppColors.legalGold, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: entry.value / 100,
                                backgroundColor: AppColors.slateAccent.withOpacity(0.1),
                                color: AppColors.legalGold,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _SectionHeader(title: 'EFFICIENCY METRICS', icon: Icons.timer),
                  const SizedBox(height: 16),
                  GlassmorphicCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Average Disposal Time', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          '${data.avgDurationDays} Days',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
