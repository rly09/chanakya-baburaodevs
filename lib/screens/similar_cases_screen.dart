import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/confidence_gauge.dart';
import '../widgets/glassmorphic_card.dart';
import 'intelligent_dashboard_screen.dart';
import 'sutra_summarizer_screen.dart';
import 'vyoohm_screen.dart';

class SimilarCasesScreen extends StatefulWidget {
  final String query;

  const SimilarCasesScreen({super.key, required this.query});

  @override
  State<SimilarCasesScreen> createState() => _SimilarCasesScreenState();
}

class _SimilarCasesScreenState extends State<SimilarCasesScreen> {
  late Future<List<CaseModel>> _casesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _casesFuture = _apiService.fetchSimilarCases(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        title: Text(
          'STRATEGIC PRECEDENTS',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.legalGold,
          ),
        ),
      ),
      body: FutureBuilder<List<CaseModel>>(
        future: _casesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.legalGold),
            );
          } else if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _casesFuture = _apiService.fetchSimilarCases(widget.query);
                });
              },
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No similar cases found.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          final cases = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              return _PremiumCaseCard(caseItem: cases[index]);
            },
          );
        },
      ),
    );
  }
}

class _PremiumCaseCard extends StatefulWidget {
  final CaseModel caseItem;

  const _PremiumCaseCard({required this.caseItem});

  @override
  State<_PremiumCaseCard> createState() => _PremiumCaseCardState();
}

class _PremiumCaseCardState extends State<_PremiumCaseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final confidence = (widget.caseItem.confidenceScore ?? 0) / 100.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: GlassmorphicCard(
        padding: EdgeInsets.zero,
        borderColor: AppColors.slateAccent.withOpacity(0.3),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        IntelligentDashboardScreen(caseItem: widget.caseItem),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConfidenceGauge(confidence: confidence, size: 60),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.caseItem.displayName,
                                style: GoogleFonts.inter(
                                  color: AppColors.legalGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'YEAR ${widget.caseItem.year}',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.caseItem.description.isNotEmpty
                          ? widget.caseItem.description
                          : 'No description available',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.caseItem.acts.map((act) => _ActChip(label: act)).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Expandable Reasoning Block
            if (widget.caseItem.explanation != null) ...[
              const Divider(height: 1),
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.legalGold,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'JURIS AI REASONING',
                        style: TextStyle(
                          color: AppColors.legalGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isExpanded)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.caseItem.explanation!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SutraSummarizerScreen(
                                    caseId: widget.caseItem.id,
                                    initialText: widget.caseItem.description,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.auto_stories, size: 16),
                              label: const Text('SUMMARIZE'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.legalGold,
                                side: BorderSide(color: AppColors.legalGold.withOpacity(0.5)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VyoohmScreen(
                                    focalCaseId: widget.caseItem.id,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.hub, size: 16),
                              label: const Text('VYOOHM'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.cyanTrend,
                                side: BorderSide(color: AppColors.cyanTrend.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActChip extends StatelessWidget {
  final String label;
  const _ActChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.slateAccent.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.slateAccent.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.crimsonLoss),
            const SizedBox(height: 24),
            const Text(
              'Intelligence Engine Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('RETRY ANALYSIS'),
            ),
          ],
        ),
      ),
    );
  }
}

