import 'package:flutter/material.dart';
import '../models/case_model.dart';

class ArgumentInsightsWidget extends StatelessWidget {
  final ArgumentIntelligence insights;

  const ArgumentInsightsWidget({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.caseCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Gauge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI ARGUMENT INSIGHTS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              insights.matchReason,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Confidence Gauge
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: insights.confidenceScore,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[200],
                      color: _getScoreColor(insights.confidenceScore),
                    ),
                  ),
                  Text(
                    '${(insights.confidenceScore * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(insights.confidenceScore),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSection(
            'SUGGESTED ARGUMENTS',
            'Winning patterns from similar cases',
            insights.suggestedArguments,
            Colors.green,
            Icons.gavel,
          ),

          const SizedBox(height: 16),

          _buildSection(
            'DEFENSE STRATEGIES',
            'Common defenses used in this context',
            insights.commonDefenseStrategies,
            Colors.orange,
            Icons.shield_outlined,
          ),

          const SizedBox(height: 16),

          _buildSection(
            'POTENTIAL WEAKNESSES',
            'Reasons for rejection in losing cases',
            insights.commonWeaknesses,
            Colors.red,
            Icons.warning_amber_rounded,
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Insights derived from ${insights.caseCount} similar cases.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score > 0.7) return Colors.green;
    if (score > 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSection(
    String title,
    String subtitle,
    List<String> items,
    MaterialColor color,
    IconData icon,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color[700]),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            color: color[50]!.withAlpha(77),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color[100]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "•",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color[700],
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
