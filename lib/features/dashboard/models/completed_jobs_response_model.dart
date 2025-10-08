class CompletedJobsResponseModel {
  final bool success;
  final int totalJobs;
  final int serviceRequestJobs;
  final int inProgressJobs;
  final int readyToReturnJobs;
  final int acceptedQuotesJobs;
  final int rejectQuotesJobs;
  final int partsNotAvailableJobs;
  final int totalServiceRequestArchive;
  final int completedJobs;
  final double completedJobsChangePercent;
  final FilterRange filterRange;

  CompletedJobsResponseModel({
    required this.success,
    required this.totalJobs,
    required this.serviceRequestJobs,
    required this.inProgressJobs,
    required this.readyToReturnJobs,
    required this.acceptedQuotesJobs,
    required this.rejectQuotesJobs,
    required this.partsNotAvailableJobs,
    required this.totalServiceRequestArchive,
    required this.completedJobs,
    required this.completedJobsChangePercent,
    required this.filterRange,
  });

  factory CompletedJobsResponseModel.fromJson(Map<String, dynamic> json) {
    return CompletedJobsResponseModel(
      success: json['success'] ?? false,
      totalJobs: json['totalJobs'] ?? 0,
      serviceRequestJobs: json['serviceRequestJobs'] ?? 0,
      inProgressJobs: json['inProgressJobs'] ?? 0,
      readyToReturnJobs: json['readyToReturnJobs'] ?? 0,
      acceptedQuotesJobs: json['acceptedQuoetsJobs'] ?? 0,
      rejectQuotesJobs: json['rejectQuoetsJobs'] ?? 0,
      partsNotAvailableJobs: json['partsNotAvailableJobs'] ?? 0,
      totalServiceRequestArchive: json['totalServiceRequestArchive'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
      completedJobsChangePercent: (json['completedJobsChangePercent'] ?? 0).toDouble(),
      filterRange: FilterRange.fromJson(json['filterRange'] ?? {}),
    );
  }
}

class FilterRange {
  final String startDate;
  final String endDate;

  FilterRange({required this.startDate, required this.endDate});

  factory FilterRange.fromJson(Map<String, dynamic> json) {
    return FilterRange(startDate: json['startDate'] ?? '', endDate: json['endDate'] ?? '');
  }
}
