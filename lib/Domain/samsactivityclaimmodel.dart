// Model class for Curriculum Activity Claim
class SAMSActivityClaimModel {

  // Unique ID for each activity claim
  String claimId;

  // Student matric number
  String studentId;

  // Name of curriculum activity
  String activityName;

  // Current claim status
  // Example: PENDING, APPROVED, REJECTED
  String status;

  // Constructor to initialize activity claim object
  SAMSActivityClaimModel({
    required this.claimId,
    required this.studentId,
    required this.activityName,
    required this.status,
  });
}
