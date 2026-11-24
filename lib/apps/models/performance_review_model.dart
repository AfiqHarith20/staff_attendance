class PerformanceGoalModel {
  final int id;
  final String title;
  final String? description;
  final String? metric;
  final String? targetDate;
  final String status;
  final String statusLabel;

  const PerformanceGoalModel({
    required this.id,
    required this.title,
    this.description,
    this.metric,
    this.targetDate,
    required this.status,
    required this.statusLabel,
  });

  factory PerformanceGoalModel.fromJson(Map<String, dynamic> json) =>
      PerformanceGoalModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        metric: json['metric'] as String?,
        targetDate: json['target_date'] as String?,
        status: json['status'] as String? ?? 'in_progress',
        statusLabel: json['status_label'] as String? ?? '',
      );
}

class PerformanceReviewModel {
  final int id;
  final String cycle;
  final String? period;
  final String status;
  final String statusLabel;
  final int? selfRating;
  final String? selfRatingLabel;
  final String? selfComment;
  final String? selfSubmittedAt;
  final int? managerRating;
  final String? managerRatingLabel;
  final String? managerComment;
  final String? managerReviewedAt;
  final String? acknowledgedAt;
  final String? acknowledgementComment;
  final String? reviewerName;
  final List<PerformanceGoalModel> goals;

  const PerformanceReviewModel({
    required this.id,
    required this.cycle,
    this.period,
    required this.status,
    required this.statusLabel,
    this.selfRating,
    this.selfRatingLabel,
    this.selfComment,
    this.selfSubmittedAt,
    this.managerRating,
    this.managerRatingLabel,
    this.managerComment,
    this.managerReviewedAt,
    this.acknowledgedAt,
    this.acknowledgementComment,
    this.reviewerName,
    required this.goals,
  });

  bool get canSelfAssess => status == 'self_assessment' || status == 'draft';
  bool get canAcknowledge => status == 'acknowledged';

  factory PerformanceReviewModel.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    return PerformanceReviewModel(
      id: json['id'] as int,
      cycle: json['cycle'] as String? ?? '',
      period: json['period'] as String?,
      status: json['status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      selfRating: (json['self_rating'] as num?)?.toInt(),
      selfRatingLabel: json['self_rating_label'] as String?,
      selfComment: json['self_comment'] as String?,
      selfSubmittedAt: json['self_submitted_at'] as String?,
      managerRating: (json['manager_rating'] as num?)?.toInt(),
      managerRatingLabel: json['manager_rating_label'] as String?,
      managerComment: json['manager_comment'] as String?,
      managerReviewedAt: json['manager_reviewed_at'] as String?,
      acknowledgedAt: json['acknowledged_at'] as String?,
      acknowledgementComment: json['acknowledgement_comment'] as String?,
      reviewerName: reviewer?['name'] as String?,
      goals: (json['goals'] as List<dynamic>? ?? [])
          .map((g) => PerformanceGoalModel.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }
}
