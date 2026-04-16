import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/glassmorphic_card.dart';

class LegalTrendTimelineScreen extends StatefulWidget {
  final String initialAct;

  const LegalTrendTimelineScreen({super.key, required this.initialAct});

  @override
  State<LegalTrendTimelineScreen> createState() =>
      _LegalTrendTimelineScreenState();
}

class _LegalTrendTimelineScreenState extends State<LegalTrendTimelineScreen> {
  late Future<List<ActTrend>> _trendsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _trendsFuture = _apiService.fetchActTrends([widget.initialAct]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        title: Text(
          'LEGAL LANDSCAPE: ${widget.initialAct.toUpperCase()}',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.legalGold,
          ),
        ),
      ),
      body: FutureBuilder<List<ActTrend>>(
        future: _trendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.legalGold),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.crimsonLoss),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trend data available.', style: TextStyle(color: AppColors.textMuted)));
          }

          final trends = snapshot.data!;
          trends.sort((a, b) => a.year.compareTo(b.year));

          double maxY = 10.0;
          if (trends.isNotEmpty) {
            double maxCases = trends
                .map((e) => e.totalCases.toDouble())
                .reduce((a, b) => a > b ? a : b);
            maxY = maxCases > 0 ? maxCases * 1.2 : 10.0;
          }

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Decadal Case Analysis',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Visualizing volume and win-rates across history.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 300,
                          child: GlassmorphicCard(
                            padding: const EdgeInsets.fromLTRB(12, 32, 24, 12),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxY,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: AppColors.surfaceHighest,
                                    tooltipPadding: const EdgeInsets.all(12),
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final trend = trends[group.x.toInt()];
                                      return BarTooltipItem(
                                        '${trend.year}\n',
                                        const TextStyle(
                                          color: AppColors.legalGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${trend.totalCases} cases',
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '\n${(trend.winRate * 100).toStringAsFixed(1)}% SUCCESS',
                                            style: const TextStyle(
                                              color: AppColors.emeraldWin,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index >= 0 && index < trends.length && index % 5 == 0) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              trends[index].year.toString(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textMuted,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  horizontalInterval: maxY / 5,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: AppColors.slateAccent.withOpacity(0.1),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: trends.asMap().entries.map((entry) {
                                  return BarChartGroupData(
                                    x: entry.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value.totalCases.toDouble(),
                                        color: AppColors.legalGold,
                                        width: 12,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: maxY,
                                          color: AppColors.slateAccent.withOpacity(0.05),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        const Text(
                          'Detailed Timeline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trend = trends[trends.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: GlassmorphicCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trend.year.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.legalGold,
                                    ),
                                  ),
                                  Text(
                                    '${trend.totalCases} Precedents',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              _MetricBadge(
                                value: '${(trend.winRate * 100).toStringAsFixed(1)}%',
                                label: 'SUCCESS RATE',
                                color: trend.winRate >= 0.5 ? AppColors.emeraldWin : AppColors.crimsonLoss,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: trends.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MetricBadge({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

