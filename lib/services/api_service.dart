import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/case_model.dart';

class JudgeNotFoundException implements Exception {
  final String message;
  final List<String> availableJudges;
  JudgeNotFoundException(this.message, this.availableJudges);
  @override
  String toString() => message;
}

class ApiService {
  // Use localhost for local Windows desktop execution
  static const String baseUrl = 'http://127.0.0.1:8000';

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
          if (data['available_judges_hint'] != null) {
            throw JudgeNotFoundException(
              data['error'],
              List<String>.from(data['available_judges_hint']),
            );
          }
          throw Exception(data['error']);
        }
        return JudgeAnalyticsModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to load judge analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is JudgeNotFoundException) rethrow;
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

  Future<String> translate(String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'target_lang': targetLang}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] ?? text;
      } else {
        return text; // Fallback to original on error
      }
    } catch (e) {
      return text;
    }
  }

  // Fetch trending cases from real news
  Future<List<String>> fetchTrendingCases() async {
    try {
      // Using NewsAPI for highly accurate, real-world Indian legal news.
      final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

      // We use Uri.https to ensure the complex 'q' parameter is correctly URL-encoded.
      // Relevancy sorting prevents getting low-quality junk news that just happens to be recent.
      final queryParams = {
        'q':
            '("Supreme Court" OR "High Court" OR "lawsuit" OR "legal") AND "India"',
        'language': 'en',
        'sortBy': 'relevancy',
        'apiKey': apiKey,
      };

      final uri = Uri.https('newsapi.org', '/v2/everything', queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> articles = decoded['articles'];

        // Return top 6 headlines, filtering out any missing titles
        return articles.take(6).map((item) {
          final title = item['title']?.toString() ?? 'Unknown Case';
          return "TRENDING: $title";
        }).toList();
      } else {
        return [
          'TRENDING: Awaiting NewsAPI Key authentication in api_service.dart.',
        ];
      }
    } catch (e) {
      return ['TRENDING: Error fetching live API news.'];
    }
  }

  // Check if backend is active
  Future<bool> checkHealth() async {
    try {
      await http
          .get(Uri.parse('$baseUrl/docs'))
          .timeout(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Petition Stress-Test — AI Red-Teams your petition
  Future<StressTestResult> fetchStressTest(String petitionText) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/stress-test'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'petition_text': petitionText}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StressTestResult.fromJson(data);
      } else {
        throw Exception('Failed to run stress test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error running stress test: $e');
    }
  }

  // Fetch dynamic act details using External Groq AI for massive general legal knowledge at extreme speeds
  Future<Map<String, String>?> fetchSpecificActDetails(String query) async {
    try {
      // Connects directly to Groq's high-speed REST API to bypass your local dataset constraint
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
        body: jsonEncode({
          'model':
              'llama-3.3-70b-versatile', // Using Llama 3.3 70B (Latest active model) for maximum legal reasoning accuracy
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Vidhi Shastra, an expert in Indian Law. Provide the exact legislative wording if it is a specific section (e.g. IPC Section 33), followed by a detailed, professional legal breakdown of its applicability and strategic implications. Do not use markdown headers, just plain formatted text.',
            },
            {
              'role': 'user',
              'content':
                  'Exhaustively analyze this specific legal query: "$query".',
            },
          ],
        }),
      )
          .timeout(
            const Duration(seconds: 15),
          ); // Groq is fast, but LLM generation varies

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final content =
              choices[0]['message']['content']?.toString() ??
              'No detailed analysis generated.';
          return {'title': query.toUpperCase(), 'content': content};
        }
        return null;
      } else if (response.statusCode == 401) {
        return {
          'title': 'API KEY REQUIRED',
          'content':
              'Please insert a valid Groq API Key in api_service.dart to use the External Intelligence Codex.',
        };
      } else {
        // Return exactly what Groq said failed (e.g. 404, 429 quota exceeded, etc.)
        return {
          'title': 'GROQ API ERROR ${response.statusCode}',
          'content': response.body,
        };
      }
    } catch (e) {
      // Return the connection error or timeout
      return {
          'title': 'CONNECTION FAILED',
          'content': e.toString(),
      };
    }
  }
}
