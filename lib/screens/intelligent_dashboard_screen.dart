import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/confidence_gauge.dart';
import '../widgets/glassmorphic_card.dart';
import 'judicial_analytics_screen.dart';
import 'court_analytics_screen.dart';
import 'sutra_summarizer_screen.dart';
import 'vyoohm_screen.dart';

class IntelligentDashboardScreen extends StatefulWidget {
  final CaseModel caseItem;

  const IntelligentDashboardScreen({super.key, required this.caseItem});

  @override
  State<IntelligentDashboardScreen> createState() => _IntelligentDashboardScreenState();
}

class _IntelligentDashboardScreenState extends State<IntelligentDashboardScreen> with SingleTickerProviderStateMixin {
  late Future<ArgumentIntelligence> _intelFuture;
  final ApiService _apiService = ApiService();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fetchIntel();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _fetchIntel() {
    setState(() {
      _intelFuture = _apiService.fetchArgumentIntelligence(
        widget.caseItem.acts,
        widget.caseItem.description,
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        title: Text(
          'INTELLIGENT DASHBOARD',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.legalGold,
          ),
        ),
        actions: [
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.1).animate(_pulseController),
            child: IconButton(
              icon: const Icon(Icons.sync, color: AppColors.legalGold),
              onPressed: _fetchIntel,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // High-Level Impact Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConfidenceGauge(
                    confidence: (widget.caseItem.confidenceScore ?? 0) / 100,
                    size: 100,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.caseItem.displayName,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.caseItem.outcome == "Win" || widget.caseItem.outcome == "1"
                                ? AppColors.emeraldWin.withOpacity(0.1)
                                : AppColors.crimsonLoss.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (widget.caseItem.outcome == "Win" || widget.caseItem.outcome == "1" ? "FAVORABLE PRECEDENT" : "ADVERSE PRECEDENT"),
                            style: TextStyle(
                              color: widget.caseItem.outcome == "Win" || widget.caseItem.outcome == "1"
                                  ? AppColors.emeraldWin
                                  : AppColors.crimsonLoss,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Analytical Command Center (Meta info)
              Row(
                children: [
                  Expanded(
                    child: _DashboardActionCard(
                      label: 'DISTRICT COURT',
                      value: widget.caseItem.courtName ?? 'SUPREME COURT',
                      icon: Icons.account_balance,
                      onTap: () {
                        if (widget.caseItem.courtName != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourtAnalyticsScreen(courtName: widget.caseItem.courtName!),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DashboardActionCard(
                      label: 'PRESIDING JUDGE',
                      value: widget.caseItem.judgeName ?? 'HON. JUSTICE',
                      icon: Icons.gavel,
                      onTap: () {
                        if (widget.caseItem.judgeName != null) {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JudicialAnalyticsScreen(judgeName: widget.caseItem.judgeName!),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _SectionHeader(title: 'ASTRA QUICK ACTIONS', icon: Icons.bolt),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Argument Intelligence Section
              _SectionHeader(title: 'STRATEGIC ARGUMENT INTELLIGENCE', icon: Icons.psychology),
              const SizedBox(height: 16),
              FutureBuilder<ArgumentIntelligence>(
                future: _intelFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: AppColors.legalGold),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError || !snapshot.hasData) {
                    return GlassmorphicCard(
                      child: Text('AI Intelligence offline. Check backend availability.', 
                      style: TextStyle(color: AppColors.crimsonLoss.withOpacity(0.7), fontSize: 13)),
                    );
                  }

                  final intel = snapshot.data!;
                  return Column(
                    children: [
                      _buildTacticStack('SUGGESTED TACTICS', intel.suggestedArguments, AppColors.legalGold),
                      const SizedBox(height: 16),
                      _buildTacticStack('COMMON WEAKNESSES', intel.commonWeaknesses, AppColors.crimsonLoss),
                      const SizedBox(height: 16),
                      _buildTacticStack('DEFENSE STRATEGIES', intel.commonDefenseStrategies, AppColors.cyanTrend),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 32),

              // Intelligence Summary Section
              _SectionHeader(title: 'SOVEREIGN INTELLIGENCE REPORT', icon: Icons.auto_awesome),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.legalGold.withOpacity(0.08),
                      AppColors.obsidianBackground,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.legalGold.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI ANALYSIS SUMMARY',
                      style: TextStyle(
                        color: AppColors.legalGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.caseItem.explanation ?? "Detailed intelligence analysis pending. AI is processing case facts and legal patterns for higher confidence results.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.7,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Full Fact Sheet
              _SectionHeader(title: 'FULL CASE FACT SHEET', icon: Icons.description),
              const SizedBox(height: 16),
              GlassmorphicCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metadata Header
                    Row(
                      children: [
                        _infoTag('ACTS: ${widget.caseItem.acts.join(", ")}', AppColors.legalGold),
                        const SizedBox(width: 8),
                        _infoTag('YEAR: ${widget.caseItem.year}', AppColors.cyanTrend),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 20),
                    Text(
                      widget.caseItem.description,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.legalGold,
              foregroundColor: AppColors.obsidianBackground,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('RETURN TO COMMAND CENTER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ),
        ),
      ),
    );
  }

  Widget _infoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTacticStack(String title, List<String> tactics, Color accentColor) {
    if (tactics.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(color: accentColor.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        ...tactics.take(3).map((tactic) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassmorphicCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.shield, color: accentColor, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tactic,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ],
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
          style: TextStyle(
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

class _DashboardActionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AppColors.legalGold, size: 20),
                const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 10),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
