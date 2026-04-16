import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../widgets/glassmorphic_card.dart';

class DharmaGPTScreen extends StatefulWidget {
  const DharmaGPTScreen({super.key});

  @override
  State<DharmaGPTScreen> createState() => _DharmaGPTScreenState();
}

class _DharmaGPTScreenState extends State<DharmaGPTScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'bot',
      'content': 'Namaste. I am Chanakya\'s Dharma-GPT. Describe your legal challenge, and I shall simulate a strategic simulation based on ancient wisdom and modern precedents.',
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userText});
      _isTyping = true;
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/dharma-gpt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'acts': ['IPC', 'CrPC'], // Generic fallback, backend handles query better
          'query': userText,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sim = data['strategy_simulation'];
        
        String responseContent = "Based on my analysis of ${data['precedent_volume']} precedents, here is your strategic simulation:\n\n";
        
        responseContent += "⚔️ **Prosecution Attack Vectors:**\n";
        for (var arg in (sim['prosecution_attack_vectors'] as List).take(2)) {
          responseContent += "• $arg\n";
        }
        
        responseContent += "\n🛡️ **Defense Counter-Moves:**\n";
        for (var def in (sim['defense_counter_moves'] as List).take(2)) {
          responseContent += "• $def\n";
        }

        responseContent += "\n⚠️ **Strategic Vulnerabilities:**\n";
        for (var weak in (sim['strategic_vulnerabilities'] as List).take(2)) {
          responseContent += "• $weak\n";
        }

        setState(() {
          _messages.add({'role': 'bot', 'content': responseContent});
        });
      } else {
        setState(() {
          _messages.add({'role': 'bot', 'content': 'The strategy engine encountered a blockage. Please rephrase.'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Connection to the tactical center lost.'});
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DHARMA-GPT STRATEGY'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.legalGold.withOpacity(0.15) : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 20),
                        ),
                        border: Border.all(
                          color: isUser ? AppColors.legalGold.withOpacity(0.3) : AppColors.slateAccent.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        msg['content'],
                        style: TextStyle(
                          color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.legalGold),
                  ),
                  const SizedBox(width: 8),
                  Text('Consulting ancient scripts...', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        border: Border(top: BorderSide(color: AppColors.slateAccent.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter case details for simulation...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.obsidianBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: AppColors.legalGold,
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.surfaceDeep),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
