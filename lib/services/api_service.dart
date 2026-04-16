import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/case_model.dart';

class ApiService {
  // Use machine local IP for physical device connection
  static const String baseUrl = 'http://10.108.5.77:8000';

  Future<List<CaseModel>> fetchSimilarCases(
    String query, {
    int topK = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/similar-cases'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query, 'top_k': topK}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => CaseModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load similar cases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching similar cases: $e');
    }
  }

  Future<WinProbability> fetchWinProbability(
    List<String> acts,
    int year,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/win-probability'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acts': acts, 'year': year}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WinProbability.fromJson(data);
      } else {
        throw Exception(
          'Failed to load win probability: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching win probability: $e');
    }
  }

  Future<ArgumentIntelligence> fetchArgumentIntelligence(
    List<String> acts,
    String query,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/argument-intelligence'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'acts': acts, 'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ArgumentIntelligence.fromJson(data);
      } else {
        throw Exception(
          'Failed to load argument intelligence: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching argument intelligence: $e');
    }
  }

  Future<List<ActTrend>> fetchActTrends(List<String> acts) async {
    try {
      // Backend expects a single act string, not a list
      final response = await http.post(
        Uri.parse('$baseUrl/act-trends'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'act': acts.isNotEmpty ? acts.first : ''}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns 'yearly_trend', not 'trends'
        final trends = data['yearly_trend'] as List;
        return trends.map((json) => ActTrend.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load act trends: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching act trends: $e');
    }
  }

  Future<JudgeAnalyticsModel> getJudgeAnalytics(String judgeName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/judge-analytics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'judge_name': judgeName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception(data['error']);
        }
        return JudgeAnalyticsModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to load judge analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching judge analytics: $e');
    }
  }

  Future<CourtAnalyticsModel> getCourtAnalytics(String courtName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/court-analytics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'court_name': courtName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] != null) {
          throw Exception(data['error']);
        }
        return CourtAnalyticsModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to load court analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching court analytics: $e');
    }
  }

  Future<TimelineResponse> fetchLegalTrendTimeline(String act) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/legal-trend-timeline'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'act': act}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TimelineResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to load legal trend timeline: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching legal trend timeline: $e');
    }
  }
}
