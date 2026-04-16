import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:graphview/GraphView.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_model.dart';
import '../utils/app_colors.dart';
import '../widgets/glassmorphic_card.dart';

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
    
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  Future<void> _fetchGraphData() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/vyoohm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'case_id': widget.focalCaseId,
          'top_k': 12,
        }),
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
      final node = Node.Id(n['id']);
      nodeMap[n['id']] = node;
      graph.addNode(node);
    }

    for (var l in linksData) {
      final source = nodeMap[l['source']];
      final target = nodeMap[l['target']];
      if (source != null && target != null) {
        graph.addEdge(source, target, paint: Paint()..color = AppColors.slateAccent.withOpacity(0.5)..strokeWidth = 1.5);
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.legalGold))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Stack(
                  children: [
                    InteractiveViewer(
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 0.01,
                      maxScale: 5.6,
                      child: GraphView(
                        graph: graph,
                        algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                        paint: Paint()
                          ..color = AppColors.legalGold
                          ..strokeWidth = 1
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          return _NodeWidget(caseId: node.key!.value as String);
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
                            const Icon(Icons.info_outline, color: AppColors.legalGold, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Viewing the strategic precedent network based on shared judicial acts and sections.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
  final String caseId;
  const _NodeWidget({required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.legalGold.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.legalGold.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description, color: AppColors.legalGold, size: 20),
          const SizedBox(height: 4),
          Text(
            CaseModel.formatCaseId(caseId),
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
