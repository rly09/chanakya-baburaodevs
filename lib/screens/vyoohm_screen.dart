import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:graphview/GraphView.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_model.dart';
import '../utils/app_colors.dart';
import '../widgets/glassmorphic_card.dart';
import 'intelligent_dashboard_screen.dart';

class VyoohmScreen extends StatefulWidget {
  final String? focalCaseId;
  const VyoohmScreen({super.key, this.focalCaseId});

  @override
  State<VyoohmScreen> createState() => _VyoohmScreenState();
}

class _VyoohmScreenState extends State<VyoohmScreen> {
  final Graph graph = Graph()..isTree = false;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGraphData();
  }

  Future<void> _fetchGraphData() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/vyoohm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'case_id': widget.focalCaseId, 'top_k': 12}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _buildGraph(data);
      } else {
        setState(() => _error = "Celestial alignment failed. (Server Error)");
      }
    } catch (e) {
      setState(() => _error = "Connection to Vyoohm Engine lost.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _buildGraph(Map<String, dynamic> data) {
    final nodesData = data['nodes'] as List;
    final linksData = data['links'] as List;

    final Map<String, Node> nodeMap = {};

    for (var n in nodesData) {
      final node = Node.Id(n); // Pass entire map as value
      nodeMap[n['id']] = node;
      graph.addNode(node);
    }

    for (var l in linksData) {
      final source = nodeMap[l['source']];
      final target = nodeMap[l['target']];
      if (source != null && target != null) {
        // Gradient-like edges with glow
        graph.addEdge(
          source,
          target,
          paint: Paint()
            ..color = AppColors.legalGold.withOpacity(0.4)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VYOOHM GRAPH'),
        backgroundColor: AppColors.obsidianBackground,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.legalGold),
            )
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : Stack(
              children: [
                InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.01,
                  maxScale: 5.6,
                  child: GraphView(
                    graph: graph,
                    algorithm: FruchtermanReingoldAlgorithm(
                      FruchtermanReingoldConfiguration(iterations: 1000),
                    ), // Force-directed algorithm is better for relation networks
                    paint: Paint()
                      ..color = AppColors.legalGold.withOpacity(0.2)
                      ..strokeWidth = 1.5
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      final data = node.key!.value as Map<String, dynamic>;
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              backgroundColor: AppColors.surfaceElevated,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: AppColors.legalGold.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              title: Text(
                                CaseModel.formatCaseId(
                                  data['id'] ?? 'Unknown Case',
                                ),
                                style: GoogleFonts.outfit(
                                  color: AppColors.legalGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Year: ${data['year'] ?? "Unknown"}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Court: ${data['court'] ?? "Unknown"}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text(
                                    'CLOSE',
                                    style: TextStyle(
                                      color: AppColors.slateAccent,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(c),
                                ),
                              ],
                            ),
                          );
                        },
                        child: _NodeWidget(nodeData: data),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: GlassmorphicCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.legalGold,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Viewing the strategic precedent network based on shared judicial acts and sections.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _NodeWidget extends StatelessWidget {
  final Map<String, dynamic> nodeData;
  const _NodeWidget({required this.nodeData});

  @override
  Widget build(BuildContext context) {
    final bool isCentral = nodeData['is_central'] == true;
    final String label =
        nodeData['label'] ?? CaseModel.formatCaseId(nodeData['id']);
    final int year = nodeData['year'] ?? 0;

    // Core styling based on node significance
    final Color mainColor = isCentral
        ? AppColors.legalGold
        : AppColors.slateAccent;
    final Color glowColor = mainColor.withOpacity(isCentral ? 0.6 : 0.2);
    final double sizeMultiplier = isCentral ? 1.4 : 1.0;

    return Container(
      constraints: BoxConstraints(maxWidth: 140 * sizeMultiplier),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * sizeMultiplier,
        vertical: 12 * sizeMultiplier,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withOpacity(0.85),
        border: Border.all(
          color: mainColor.withOpacity(0.7),
          width: isCentral ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: isCentral ? 25 : 10,
            spreadRadius: isCentral ? 5 : 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCentral ? Icons.star : Icons.description_outlined,
            color:
                AppColors.legalGold, // Set icon color explicitly to yellow/gold
            size: 24 * sizeMultiplier,
          ),
          SizedBox(height: 8 * sizeMultiplier),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontWeight: isCentral ? FontWeight.bold : FontWeight.w600,
              fontSize: 12 * sizeMultiplier,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (year > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                year.toString(),
                style: TextStyle(
                  color: AppColors
                      .legalGold, // Set year text color explicitly to yellow/gold
                  fontSize: 10 * sizeMultiplier,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
