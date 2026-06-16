class SAMSAttendanceModel {

  // Attendance record attributes
  final String attendanceID;
  final String studentID;
  final String studentName;
  final String subCode;
  final String subName;
  final String classCode;
  final String section;
  final String classSession;
  final String sessionDate;
  final String sessionTime;
  final String attendanceStatus;

  SAMSAttendanceModel({
    required this.attendanceID,
    required this.studentID,
    required this.studentName,
    required this.subCode,
    required this.subName,
    required this.classCode,
    required this.section,
    required this.classSession,
    required this.sessionDate,
    required this.sessionTime,
    required this.attendanceStatus,
  });

  // Create model object from Firestore data
  factory SAMSAttendanceModel.fromMap(Map<String, dynamic> data) {
    return SAMSAttendanceModel(
      attendanceID: data['attendanceID'] ?? '',
      studentID: data['studentID'] ?? '',
      studentName: data['studentName'] ?? '',
      subCode: data['subCode'] ?? '',
      subName: data['subName'] ?? '',
      classCode: data['classCode'] ?? '',
      section: data['section'] ?? '',
      classSession: data['classSession'] ?? '',
      sessionDate: data['sessionDate'] ?? '',
      sessionTime: data['sessionTime'] ?? '',
      attendanceStatus: data['attendanceStatus'] ?? '',
    );
  }

  // Convert model object into Firestore format
  Map<String, dynamic> toMap() {
    return {
      'attendanceID': attendanceID,
      'studentID': studentID,
      'studentName': studentName,
      'subCode': subCode,
      'subName': subName,
      'classCode': classCode,
      'section': section,
      'classSession': classSession,
      'sessionDate': sessionDate,
      'sessionTime': sessionTime,
      'attendanceStatus': attendanceStatus,
    };
  }
}
