import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import 'glassmorphic_card.dart';

class CommandCenterInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final VoidCallback onSubmitted;

  const CommandCenterInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 5,
    required this.onSubmitted,
  });

  @override
  State<CommandCenterInput> createState() => _CommandCenterInputState();
}

class _CommandCenterInputState extends State<CommandCenterInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  
  bool _isBackendRunning = false;
  Timer? _healthTimer;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    _checkHealth();
    _healthTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkHealth());
  }

  Future<void> _checkHealth() async {
    final isRunning = await _apiService.checkHealth();
    if (mounted && isRunning != _isBackendRunning) {
      setState(() {
        _isBackendRunning = isRunning;
      });
    }
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GlassmorphicCard(
          padding: EdgeInsets.zero,
          borderColor: _isFocused
              ? AppColors.primary.withOpacity(
                  0.5 + (_glowAnimation.value / 8),
                )
              : AppColors.border.withOpacity(0.2),
          child: Column(
            children: [
              TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                maxLines: widget.maxLines,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColors.textMuted.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.all(24),
                  border: InputBorder.none,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _isBackendRunning ? 'AI ENGINE ACTIVE' : 'AI ENGINE OFFLINE',
                      style: TextStyle(
                        color: _isBackendRunning
                            ? (_isFocused ? AppColors.primary : AppColors.textMuted)
                            : Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isBackendRunning
                            ? Colors.green // Always green if running
                            : Colors.redAccent, // Red if offline
                        boxShadow: [
                          if (_isBackendRunning)
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5 + (_glowAnimation.value / 8)), // Blinking green
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
