import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chanakya/providers/language_provider.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/glassmorphic_card.dart';

class JudicialAnalyticsScreen extends StatefulWidget {
  final String? judgeName;

  const JudicialAnalyticsScreen({super.key, this.judgeName});

  @override
  State<JudicialAnalyticsScreen> createState() =>
      _JudicialAnalyticsScreenState();
}

class _JudicialAnalyticsScreenState extends State<JudicialAnalyticsScreen> {
  Future<JudgeAnalyticsModel>? _analyticsFuture;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.judgeName != null &&
        widget.judgeName!.isNotEmpty &&
        widget.judgeName != 'Unknown Judge' &&
        widget.judgeName != 'HON. JUSTICE') {
      _searchController.text = widget.judgeName!;
      _analyticsFuture = _apiService.getJudgeAnalytics(widget.judgeName!);
    }
  }

  void _searchJudge(String name) {
    if (name.trim().isEmpty) return;
    FocusScope.of(context).unfocus(); // Close keyboard after search
    setState(() {
      _analyticsFuture = _apiService.getJudgeAnalytics(name.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        title: Text(
          languageProvider.translate('JUDICIAL INTELLIGENCE'),
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.legalGold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search Judge Name...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.legalGold,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.legalGold,
                  ),
                  onPressed: () => _searchJudge(_searchController.text),
                ),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onSubmitted: _searchJudge,
            ),
          ),
          Expanded(
            child: _analyticsFuture == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: AppColors.slateAccent.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'SEARCH JUDICIAL DATABASE',
                          style: TextStyle(
                            color: AppColors.legalGold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter a judge\'s name above to view their comprehensive analytics.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : FutureBuilder<JudgeAnalyticsModel>(
                    future: _analyticsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.legalGold,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        final errorString = snapshot.error
                            .toString()
                            .replaceAll('Exception: ', '');
                        Widget hintWidget = const SizedBox();
                        if (snapshot.error is JudgeNotFoundException) {
                          final jError =
                              snapshot.error as JudgeNotFoundException;
                          if (jError.availableJudges.isNotEmpty) {
                            hintWidget = Column(
                              children: [
                                const SizedBox(height: 32),
                                const Text(
                                  'AVAILABLE BENCH PROFILES',
                                  style: TextStyle(
                                    color: AppColors.cyanTrend,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: jError.availableJudges
                                      .map(
                                        (name) => ActionChip(
                                          label: Text(
                                            name,
                                            style: const TextStyle(
                                              color:
                                                  AppColors.obsidianBackground,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor: AppColors.cyanTrend,
                                          onPressed: () {
                                            _searchController.text = name;
                                            _searchJudge(name);
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            );
                          }
                        }

                        return Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.gavel,
                                  size: 48,
                                  color: AppColors.slateAccent,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'JUDICIAL RECORD NOT FOUND',
                                  style: TextStyle(
                                    color: AppColors.legalGold,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  errorString,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                hintWidget,
                              ],
                            ),
                          ),
                        );
                      }

                      final data = snapshot.data!;
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
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
                                        border: Border.all(
                                          color: AppColors.legalGold,
                                          width: 2,
                                        ),
                                        color: AppColors.surface,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.legalGold,
                                      ),
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
                                      value:
                                          '${data.winRate.toStringAsFixed(1)}%',
                                      icon: Icons.trending_up,
                                      color: data.winRate >= 50.0
                                          ? AppColors.emeraldWin
                                          : AppColors.crimsonLoss,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              _SectionHeader(
                                title: 'FREQUENTLY CITED ACTS',
                                icon: Icons.history,
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: data.frequentLaws
                                    .map(
                                      (law) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.legalGold
                                              .withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.legalGold
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        child: Text(
                                          law,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),

                              _SectionHeader(
                                title: 'PREDICTIVE BENCHMARKS (WIN %)',
                                icon: Icons.analytics,
                              ),
                              const SizedBox(height: 16),
                              if (data.predictiveBenchmarks.isEmpty)
                                const Text(
                                  'Insufficient data for predictive benchmarking.',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                )
                              else
                                Column(
                                  children: data.predictiveBenchmarks.entries
                                      .map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  entry.key,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: LinearProgressIndicator(
                                                    value: entry.value / 100.0,
                                                    backgroundColor: AppColors
                                                        .surfaceElevated,
                                                    color: entry.value >= 50.0
                                                        ? AppColors.emeraldWin
                                                        : AppColors.crimsonLoss,
                                                    minHeight: 8,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                '${entry.value}%',
                                                style: TextStyle(
                                                  color: entry.value >= 50.0
                                                      ? AppColors.emeraldWin
                                                      : AppColors.crimsonLoss,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),

                              const SizedBox(height: 32),
                              _SectionHeader(
                                title: 'JUDICIAL STANCE',
                                icon: Icons.psychology,
                              ),
                              const SizedBox(height: 16),
                              GlassmorphicCard(
                                child: Text(
                                  'This presiding justice shows a consistent ${data.winRate >= 50.0 ? "favorable" : "critical"} pattern regarding cited Acts. Average case duration is recorded at ${data.avgDurationDays} days, indicating a ${data.avgDurationDays < 365 ? "rapid" : "meticulous"} disposal speed.',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? AppColors.legalGold, size: 24),
          const SizedBox(height: 16),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
