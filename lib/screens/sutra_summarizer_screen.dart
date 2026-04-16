import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../widgets/glassmorphic_card.dart';

class SutraSummarizerScreen extends StatefulWidget {
  final String? caseId;
  final String? initialText;
  const SutraSummarizerScreen({super.key, this.caseId, this.initialText});

  @override
  State<SutraSummarizerScreen> createState() => _SutraSummarizerScreenState();
}

class _SutraSummarizerScreenState extends State<SutraSummarizerScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _sutras = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _controller.text = widget.initialText!;
      _summarize();
    } else if (widget.caseId != null) {
      _summarize();
    }
  }

  Future<void> _summarize() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/sutra-summarizer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'case_id': widget.caseId,
          'text': _controller.text.isNotEmpty ? _controller.text : null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _sutras = List<String>.from(data['sutras']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to extract wisdom from the text.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUTRA SUMMARIZER'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.caseId == null) ...[
               Text(
                'INPUT LEGAL TEXT',
                style: TextStyle(color: AppColors.legalGold.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 8,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Paste judgment text here...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _summarize,
                  child: const Text('GENERATE 5 SUTRAS'),
                ),
              ),
              const SizedBox(height: 48),
            ],
            
            Row(
              children: [
                const Icon(Icons.auto_stories, color: AppColors.legalGold, size: 24),
                const SizedBox(width: 12),
                Text(
                  'THE 5 SUTRAS (WISDOM)',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.legalGold))
            else if (_sutras.isEmpty)
              Center(child: Text('No sutras generated yet.', style: TextStyle(color: AppColors.textMuted)))
            else
              ...List.generate(_sutras.length, (index) => _buildSutraCard(index, _sutras[index])),
          ],
        ),
      ),
    );
  }

  Widget _buildSutraCard(int index, String text) {
    return FadeInRight(
      delay: Duration(milliseconds: index * 100),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.legalGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.legalGold.withOpacity(0.3)),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: AppColors.legalGold, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
