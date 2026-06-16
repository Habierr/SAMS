class SAMSActivityClaimModel {

  // Unique claim document ID
  String claimId;

  // Student matric number
  String studentId;

  // Activity name
  String activityName;

  // Activity date
  String activityDate;

  // Activity duration
  String durationHours;

  // Activity description
  String description;

  // Supporting document name
  String supportingFileName;

  // Supporting document path
  String supportingFilePath;

  // Claim status
  String status;

  // Rejection reason if claim rejected
  String rejectionReason;

  SAMSActivityClaimModel({
    required this.claimId,
    required this.studentId,
    required this.activityName,
    required this.activityDate,
    required this.durationHours,
    required this.description,
    required this.supportingFileName,
    required this.supportingFilePath,
    required this.status,
    required this.rejectionReason,
  });
}
