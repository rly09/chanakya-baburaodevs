class CaseModel {
  final String id;
  final int year;
  final List<String> acts;
  final String outcome;
  final String description;
  final double? similarityScore;
  final double? confidenceScore;
  final List<String>? matchedPhrases;
  final String? explanation;
  final String? judgeName;
  final String? courtName;

  static String formatCaseId(String id) {
    if (id.isEmpty) return 'Unknown Case';
    // Remove leading/trailing underscores and replace internal ones with spaces
    String formatted = id.replaceAll(RegExp(r'^_+|_+$'), '').replaceAll('_', ' ').trim();
    if (formatted.isEmpty) return 'Unknown Case';
    
    // Capitalize each word (Title Case)
    return formatted.split(' ').map((word) {
      if (word.isEmpty) return '';
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String get displayName => formatCaseId(id);

  CaseModel({
    required this.id,
    required this.year,
    required this.acts,
    required this.outcome,
    this.description = '',
    this.similarityScore,
    this.confidenceScore,
    this.matchedPhrases,
    this.explanation,
    this.judgeName,
    this.courtName,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['case_id'] ?? json['id'] ?? 'Unknown ID',
      year: json['year'] ?? 0,
      acts: (json['acts'] is String)
          ? [json['acts']]
          : List<String>.from(json['acts'] ?? []),
      outcome: json['outcome'] ?? 'Pending',
      description: json['description'] ?? '',
      similarityScore: json['similarity_score']?.toDouble(),
      confidenceScore: json['confidence_score']?.toDouble(),
      matchedPhrases: json['matched_phrases'] != null
          ? List<String>.from(json['matched_phrases'])
          : null,
      explanation: json['explanation'],
      judgeName: json['judge_name'],
      courtName: json['court_name'],
    );
  }
}

class WinProbability {
  final double winRate;
  final int totalCases;
  final int successfulCases;

  WinProbability({
    required this.winRate,
    required this.totalCases,
    required this.successfulCases,
  });

  factory WinProbability.fromJson(Map<String, dynamic> json) {
    double rawWinRate = (json['historical_win_probability'] ?? 0.0).toDouble();
    // Normalize if it's > 1 (e.g. 85.0 -> 0.85)
    if (rawWinRate > 1.0) {
      rawWinRate /= 100.0;
    }
    // Clamp to ensure it's between 0.0 and 1.0
    rawWinRate = rawWinRate.clamp(0.0, 1.0);

    return WinProbability(
      winRate: rawWinRate,
      totalCases: json['total_cases'] ?? 0,
      successfulCases: json['successful_cases'] ?? 0,
    );
  }
}

class ActTrend {
  final int year;
  final int totalCases;
  final double winRate;

  ActTrend({
    required this.year,
    required this.totalCases,
    required this.winRate,
  });

  factory ActTrend.fromJson(Map<String, dynamic> json) {
    double rawWinRate = (json['win_percentage'] ?? 0.0).toDouble();
    // Normalize
    if (rawWinRate > 1.0) {
      rawWinRate /= 100.0;
    }
    // Clamp
    rawWinRate = rawWinRate.clamp(0.0, 1.0);

    return ActTrend(
      year: json['year'] ?? 0,
      totalCases: json['total_cases'] ?? 0,
      winRate: rawWinRate,
    );
  }
}

class ArgumentIntelligence {
  final List<String> suggestedArguments;
  final List<String> commonDefenseStrategies;
  final List<String> commonWeaknesses;
  final double confidenceScore;
  final int caseCount;
  final String matchReason;

  ArgumentIntelligence({
    required this.suggestedArguments,
    required this.commonDefenseStrategies,
    required this.commonWeaknesses,
    required this.confidenceScore,
    required this.caseCount,
    this.matchReason = 'Based on legal precedents',
  });

  factory ArgumentIntelligence.fromJson(Map<String, dynamic> json) {
    return ArgumentIntelligence(
      suggestedArguments: List<String>.from(json['suggested_arguments'] ?? []),
      commonDefenseStrategies: List<String>.from(
        json['common_defense_strategies'] ?? [],
      ),
      commonWeaknesses: List<String>.from(
        json['common_weaknesses_in_losing_cases'] ?? [],
      ),
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      caseCount: json['case_count'] ?? 0,
      matchReason: json['match_reason'] ?? 'Based on analysis of similar cases',
    );
  }
}

class JudgeAnalyticsModel {
  final String judgeName;
  final int totalCases;
  final double winRate;
  final int avgDurationDays;
  final List<String> frequentLaws;
  final Map<String, double> predictiveBenchmarks;

  JudgeAnalyticsModel({
    required this.judgeName,
    required this.totalCases,
    required this.winRate,
    required this.avgDurationDays,
    required this.frequentLaws,
    required this.predictiveBenchmarks,
  });

  factory JudgeAnalyticsModel.fromJson(Map<String, dynamic> json) {
    var benchJson = json['predictive_benchmarks'] as Map<String, dynamic>?;
    Map<String, double> bench = {};
    if (benchJson != null) {
      benchJson.forEach((key, value) {
        bench[key] = (value ?? 0.0).toDouble();
      });
    }

    return JudgeAnalyticsModel(
      judgeName: json['judge_name'] ?? '',
      totalCases: json['total_cases'] ?? 0,
      winRate: (json['win_rate'] ?? 0.0).toDouble(),
      avgDurationDays: json['average_case_duration_days'] ?? 0,
      frequentLaws: List<String>.from(json['frequently_cited_laws'] ?? []),
      predictiveBenchmarks: bench,
    );
  }
}

class CourtAnalyticsModel {
  final String courtName;
  final int totalCases;
  final int avgDurationDays;
  final String disposalSpeed;
  final Map<String, double> actDistribution;

  CourtAnalyticsModel({
    required this.courtName,
    required this.totalCases,
    required this.avgDurationDays,
    required this.disposalSpeed,
    required this.actDistribution,
  });

  factory CourtAnalyticsModel.fromJson(Map<String, dynamic> json) {
    var actDistJson = json['act_distribution'];
    Map<String, double> actDist = {};
    if (actDistJson != null) {
      actDistJson.forEach((key, value) {
        actDist[key] = (value ?? 0.0).toDouble();
      });
    }

    return CourtAnalyticsModel(
      courtName: json['court_name'] ?? '',
      totalCases: json['total_cases'] ?? 0,
      avgDurationDays: json['average_case_duration_days'] ?? 0,
      disposalSpeed: json['disposal_speed'] ?? '',
      actDistribution: actDist,
    );
  }
}

class TimelineResponse {
  final String act;
  final List<YearlyData> yearlyData;
  final List<LandmarkEvent> landmarkEvents;

  TimelineResponse({
    required this.act,
    required this.yearlyData,
    required this.landmarkEvents,
  });

  factory TimelineResponse.fromJson(Map<String, dynamic> json) {
    return TimelineResponse(
      act: json['act'] ?? '',
      yearlyData:
          (json['yearly_data'] as List?)
              ?.map((e) => YearlyData.fromJson(e))
              .toList() ??
          [],
      landmarkEvents:
          (json['landmark_events'] as List?)
              ?.map((e) => LandmarkEvent.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class YearlyData {
  final int year;
  final int totalCases;
  final double winRate;

  YearlyData({
    required this.year,
    required this.totalCases,
    required this.winRate,
  });

  factory YearlyData.fromJson(Map<String, dynamic> json) {
    return YearlyData(
      year: json['year'] ?? 0,
      totalCases: json['total_cases'] ?? 0,
      winRate: (json['win_rate'] ?? 0.0).toDouble(),
    );
  }
}

class LandmarkEvent {
  final int year;
  final String title;
  final String description;
  final String caseId;
  final String caseSnippet;

  LandmarkEvent({
    required this.year,
    required this.title,
    required this.description,
    required this.caseId,
    required this.caseSnippet,
  });

  factory LandmarkEvent.fromJson(Map<String, dynamic> json) {
    return LandmarkEvent(
      year: json['year'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      caseId: json['case_id'] ?? '',
      caseSnippet: json['case_snippet'] ?? '',
    );
  }
}
