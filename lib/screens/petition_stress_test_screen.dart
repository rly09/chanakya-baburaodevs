import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class PetitionStressTestScreen extends StatefulWidget {
  const PetitionStressTestScreen({super.key});

  @override
  State<PetitionStressTestScreen> createState() =>
      _PetitionStressTestScreenState();
}

class _PetitionStressTestScreenState extends State<PetitionStressTestScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  StressTestResult? _result;
  bool _isAnalyzing = false;
  String? _error;

  // Gauge animation
  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;

  // Pulse animation for the analyzing state
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Stagger animations for result sections
  late AnimationController _staggerController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _gaugeAnimation = CurvedAnimation(
      parent: _gaugeController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _gaugeController.dispose();
    _pulseController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _runStressTest() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _result = null;
      _error = null;
    });

    _gaugeController.reset();
    _staggerController.reset();

    try {
      final result = await _apiService.fetchStressTest(text);
      if (!mounted) return;
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
      // Animate gauge and then fade results
      _gaugeController.forward();
      await Future.delayed(const Duration(milliseconds: 400));
      _staggerController.forward();
      // Scroll to results
      await Future.delayed(const Duration(milliseconds: 200));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          400,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Color _gradeColor(String gradeColor) {
    switch (gradeColor) {
      case 'emerald':
        return const Color(0xFF10B981);
      case 'gold':
        return const Color(0xFFF59E0B);
      case 'orange':
        return const Color(0xFFEF6C00);
      case 'crimson':
        return const Color(0xFFDC2626);
      default:
        return AppColors.legalGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AGNI PARIKSHA',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header tagline
            _HeaderBanner(),
            const SizedBox(height: 28),

            // Input area
            _PetitionInput(
              controller: _controller,
              isAnalyzing: _isAnalyzing,
              onAnalyze: _runStressTest,
            ),

            // Analyzing loader
            if (_isAnalyzing) ...[
              const SizedBox(height: 40),
              _AnalyzingLoader(pulse: _pulseAnimation),
            ],

            // Error state
            if (_error != null && !_isAnalyzing) ...[
              const SizedBox(height: 32),
              _ErrorCard(message: _error!),
            ],

            // Results
            if (_result != null && !_isAnalyzing) ...[
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Strength Gauge
                    _StrengthGaugeCard(
                      result: _result!,
                      animation: _gaugeAnimation,
                      gradeColor: _gradeColor(_result!.gradeColor),
                    ),
                    const SizedBox(height: 24),

                    // Verdict
                    _VerdictCard(
                      verdict: _result!.verdict,
                      precedents: _result!.precedentsAnalyzed,
                    ),
                    const SizedBox(height: 24),

                    // Detected Acts
                    if (_result!.detectedActs.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.gavel,
                        label: 'ACTS DETECTED IN YOUR PETITION',
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 12),
                      _ActsChips(acts: _result!.detectedActs),
                      const SizedBox(height: 24),
                    ],

                    // Strongest Argument
                    _SectionHeader(
                      icon: Icons.military_tech,
                      label: 'YOUR STRONGEST POINT',
                      color: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 12),
                    _InsightCard(
                      text: _result!.strongestArgument,
                      borderColor: const Color(0xFF059669),
                      iconColor: const Color(0xFF059669),
                      icon: Icons.check_circle_outline,
                      bgColor: const Color(0xFFF0FDF4),
                    ),
                    const SizedBox(height: 24),

                    // Weakest Arguments
                    if (_result!.weakestArguments.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.warning_amber_rounded,
                        label: 'WEAKEST ARGUMENTS — FIX BEFORE FILING',
                        color: const Color(0xFFDC2626),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        _result!.weakestArguments.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _InsightCard(
                            text: _result!.weakestArguments[i],
                            borderColor: const Color(0xFFDC2626),
                            iconColor: const Color(0xFFDC2626),
                            icon: Icons.close_rounded,
                            bgColor: const Color(0xFFFFF5F5),
                            badge: 'WEAKNESS ${i + 1}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Counter Cases
                    if (_result!.counterCases.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.shield_outlined,
                        label: 'OPPONENT\'S LIKELY COUNTER-ARGUMENTS',
                        color: const Color(0xFFEF6C00),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        _result!.counterCases.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _InsightCard(
                            text: _result!.counterCases[i],
                            borderColor: const Color(0xFFEF6C00),
                            iconColor: const Color(0xFFEF6C00),
                            icon: Icons.remove_circle_outline,
                            bgColor: const Color(0xFFFFF8F0),
                            badge: 'COUNTER ${i + 1}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // CTA footer
                    _FooterCta(),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header banner
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.biotech,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agni Pariksha',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Trial by Fire — Sanskrit: अग्नि परीक्षा',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Know your weaknesses before opposing counsel does.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Petition Input
// ─────────────────────────────────────────────────────────────────────────────
class _PetitionInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isAnalyzing;
  final VoidCallback onAnalyze;

  const _PetitionInput({
    required this.controller,
    required this.isAnalyzing,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'SUBMIT YOUR PETITION FOR TRIAL BY FIRE',
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            minLines: 6,
            maxLines: 12,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText:
                  'Paste your petition, plaint, or describe the facts and legal acts involved...\n\nExample: "The petitioner files this writ under Article 226 challenging the order passed under IPC Section 420 and CrPC Section 156..."',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.6,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: isAnalyzing ? null : onAnalyze,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isAnalyzing ? Icons.hourglass_top : Icons.biotech,
                  size: 20,
                  color: isAnalyzing ? AppColors.textMuted : Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  isAnalyzing ? 'CONSULTING PRECEDENTS...' : 'BEGIN AGNI PARIKSHA',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 13,
                    color: isAnalyzing ? AppColors.textMuted : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Analyzing Loader
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyzingLoader extends StatelessWidget {
  final Animation<double> pulse;
  const _AnalyzingLoader({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        return Column(
          children: [
            Opacity(
              opacity: pulse.value,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 48,
                      width: 48,
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'AGNI PARIKSHA IN PROGRESS',
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Putting your petition through the trial by fire...',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Strength Gauge Card
// ─────────────────────────────────────────────────────────────────────────────
class _StrengthGaugeCard extends StatelessWidget {
  final StressTestResult result;
  final Animation<double> animation;
  final Color gradeColor;

  const _StrengthGaugeCard({
    required this.result,
    required this.animation,
    required this.gradeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'AGNI PARIKSHA VERDICT',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final progress = animation.value * (result.strengthScore / 100.0);
              return SizedBox(
                height: 180,
                width: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shadow glow
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: gradeColor.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Arc painter
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _ScoreArcPainter(
                        progress: progress,
                        color: gradeColor,
                        bgColor: AppColors.surfaceElevated,
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(animation.value * result.strengthScore).toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          '/ 100',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Grade badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: gradeColor.withOpacity(0.3), width: 1),
            ),
            child: Text(
              result.grade,
              style: GoogleFonts.outfit(
                color: gradeColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stat row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(
                label: 'PRECEDENTS',
                value: '${result.precedentsAnalyzed}',
              ),
              _StatPill(
                label: 'ACTS FOUND',
                value: '${result.detectedActs.length}',
              ),
              _StatPill(
                label: 'RISKS',
                value: '${result.weakestArguments.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// Semi-circle arc painter
class _ScoreArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _ScoreArcPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 12;
    const strokeWidth = 14.0;

    // Background track
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Verdict Card
// ─────────────────────────────────────────────────────────────────────────────
class _VerdictCard extends StatelessWidget {
  final String verdict;
  final int precedents;
  const _VerdictCard({required this.verdict, required this.precedents});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              verdict,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Acts Chips
// ─────────────────────────────────────────────────────────────────────────────
class _ActsChips extends StatelessWidget {
  final List<String> acts;
  const _ActsChips({required this.acts});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: acts.map((act) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            act,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Insight Card (used for strengths, weaknesses, counters)
// ─────────────────────────────────────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color iconColor;
  final Color bgColor;
  final IconData icon;
  final String? badge;

  const _InsightCard({
    required this.text,
    required this.borderColor,
    required this.iconColor,
    required this.bgColor,
    required this.icon,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null) ...[
                  Text(
                    badge!,
                    style: GoogleFonts.inter(
                      color: iconColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Card
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFFDC2626),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer CTA
// ─────────────────────────────────────────────────────────────────────────────
class _FooterCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT STEPS',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Address each flagged weakness and re-run the stress test until your score exceeds 75 before filing.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
