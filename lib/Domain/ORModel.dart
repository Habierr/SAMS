// ─────────────────────────────────────────────────────────────────────────────
// FILE: lib/Domain/ORModel.dart
// Entity Class — PACK112-SAMS-2026
// Ref: SDD Section 4.1.12 ORModel
// Handles all database operations for the Open Registration module.
// ─────────────────────────────────────────────────────────────────────────────

// ═══════════════════════════════════════════════════════════════════════════
// REGISTRAR TABLE (Data Dictionary SDD Page 20)
// ═══════════════════════════════════════════════════════════════════════════
class Registrar {
  String regisID;
  String name;
  String email;
  String password;

  Registrar({
    required this.regisID,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
        'regisID': regisID,
        'name': name,
        'email': email,
        'password': password,
      };

  factory Registrar.fromMap(Map<String, dynamic> map) => Registrar(
        regisID: map['regisID'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        password: map['password'] ?? '',
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// SUBJECT TABLE (Data Dictionary SDD Page 20)
// ═══════════════════════════════════════════════════════════════════════════
class Subject {
  String subCode;
  String subName;
  int creditHour;
  String faculty;

  Subject({
    required this.subCode,
    required this.subName,
    required this.creditHour,
    required this.faculty,
  });

  Map<String, dynamic> toMap() => {
        'subCode': subCode,
        'subName': subName,
        'creditHour': creditHour,
        'faculty': faculty,
      };

  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
        subCode: map['subCode'] ?? '',
        subName: map['subName'] ?? '',
        creditHour: map['creditHour'] ?? 0,
        faculty: map['faculty'] ?? '',
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION TABLE / OFFERING REGISTRATION (Data Dictionary SDD Page 20-21)
// Used by Registrar: AddOR, EditOR, SubjectOffering
// Used by Student:   CourseRegistration (viewSection, displayAvailableSubject)
// ═══════════════════════════════════════════════════════════════════════════
class OfferingRegistration {
  String sectID;
  String subCode;
  String subName; // denormalised — untuk display di student page
  String classType; // ENUM: 'Lecture' | 'Lab'
  String sectNo;
  int quota;
  int enrolled;
  String lectName;
  String days;
  String startTime;
  String endTime;
  String venue;
  String semester;
  String session;

  OfferingRegistration({
    required this.sectID,
    required this.subCode,
    required this.subName,
    required this.classType,
    required this.sectNo,
    required this.quota,
    required this.enrolled,
    required this.lectName,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.semester,
    required this.session,
  });

  // ── Derived helpers (untuk CourseRegistration student page) ──────────────
  bool get isFull => enrolled >= quota;
  double get fillPercentage => quota > 0 ? enrolled / quota : 0;
  String get enrollmentLabel => '$enrolled/$quota';
  String get scheduleLabel => '$days $startTime-$endTime . $venue';
  bool get isLecture => classType == 'Lecture';
  bool get isLab => classType == 'Lab';

  Map<String, dynamic> toMap() => {
        'sectID': sectID,
        'subCode': subCode,
        'subName': subName,
        'classType': classType,
        'sectNo': sectNo,
        'quota': quota,
        'enrolled': enrolled,
        'lectName': lectName,
        'days': days,
        'startTime': startTime,
        'endTime': endTime,
        'venue': venue,
        'semester': semester,
        'session': session,
      };

  factory OfferingRegistration.fromMap(Map<String, dynamic> map) =>
      OfferingRegistration(
        sectID: map['sectID'] ?? '',
        subCode: map['subCode'] ?? '',
        subName: map['subName'] ?? '',
        classType: map['classType'] ?? '',
        sectNo: map['sectNo'] ?? '',
        quota: map['quota'] ?? 0,
        enrolled: map['enrolled'] ?? 0,
        lectName: map['lectName'] ?? '',
        days: map['days'] ?? '',
        startTime: map['startTime'] ?? '',
        endTime: map['endTime'] ?? '',
        venue: map['venue'] ?? '',
        semester: map['semester'] ?? '',
        session: map['session'] ?? '',
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// OR SESSION TABLE (Data Dictionary SDD Page 28-29)
// Used by Registrar: SetSchedule (activateORSession, saveSchedule)
// Used by Student:   StudentOR (displayORStatus)
// ═══════════════════════════════════════════════════════════════════════════
class ORSession {
  String sessionID;
  String semester;
  bool isActive;
  String studentYear;
  DateTime startDate;
  DateTime endDate;
  String startTime;
  String endTime;

  ORSession({
    required this.sessionID,
    required this.semester,
    required this.isActive,
    required this.studentYear,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
  });

  // ── Derived helper — formatted date range untuk banner ───────────────────
  // e.g. "14 Apr - 16 Apr"
  String get displayDateRange {
    String _fmt(DateTime d) {
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${d.day} ${months[d.month]}';
    }

    return '${_fmt(startDate)} - ${_fmt(endDate)}';
  }

  Map<String, dynamic> toMap() => {
        'sessionID': sessionID,
        'semester': semester,
        'isActive': isActive,
        'studentYear': studentYear,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
      };

  factory ORSession.fromMap(Map<String, dynamic> map) => ORSession(
        sessionID: map['sessionID'] ?? '',
        semester: map['semester'] ?? '',
        isActive: map['isActive'] ?? false,
        studentYear: map['studentYear'] ?? '',
        startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now(),
        startTime: map['startTime'] ?? '',
        endTime: map['endTime'] ?? '',
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// REGISTRATION TABLE (Data Dictionary SDD Page 21-22)
// BAHAGIAN STUDENT SAHAJA — rekod pendaftaran kursus oleh student
// Ref: SDD 4.1.8 CourseRegistration, 4.1.9 RegisteredCourse
// ═══════════════════════════════════════════════════════════════════════════
class CourseRegistrationRecord {
  String regID; // PK VARCHAR(10)
  String studentID; // FK VARCHAR(10)
  String sectID; // FK VARCHAR(10) — section yang dipilih student
  String sessionID; // FK VARCHAR(10) — OR session semasa
  int totalSub; // INT — jumlah subject student dalam session ini
  String regStatus; // ENUM: 'Registered' | 'Dropped' | 'Edited'
  DateTime regAt; // DATETIME — masa student daftar

  // Denormalised fields — dari Subject + OfferingRegistration (untuk display)
  String subCode;
  String subName;
  int creditHour;
  String classType; // 'Lecture' | 'Lab'
  String sectNo;
  String lectName;
  String days;
  String startTime;
  String endTime;
  String venue;
  String semester;

  CourseRegistrationRecord({
    required this.regID,
    required this.studentID,
    required this.sectID,
    required this.sessionID,
    required this.totalSub,
    required this.regStatus,
    required this.regAt,
    this.subCode = '',
    this.subName = '',
    this.creditHour = 0,
    this.classType = '',
    this.sectNo = '',
    this.lectName = '',
    this.days = '',
    this.startTime = '',
    this.endTime = '',
    this.venue = '',
    this.semester = '',
  });

  // ── Derived helpers ────────────────────────────────────────────────────
  bool get isLecture => classType == 'Lecture';
  bool get isLab => classType == 'Lab';
  String get scheduleLabel => '$days $startTime-$endTime . $venue';

  // saveOR() — SDD 4.1.12: Save the Open Registration data in the database.
  Map<String, dynamic> saveOR() => toMap();

  Map<String, dynamic> toMap() => {
        'regID': regID,
        'studentID': studentID,
        'sectID': sectID,
        'sessionID': sessionID,
        'totalSub': totalSub,
        'regStatus': regStatus,
        'regAt': regAt.toIso8601String(),
        'subCode': subCode,
        'subName': subName,
        'creditHour': creditHour,
        'classType': classType,
        'sectNo': sectNo,
        'lectName': lectName,
        'days': days,
        'startTime': startTime,
        'endTime': endTime,
        'venue': venue,
        'semester': semester,
      };

  factory CourseRegistrationRecord.fromMap(Map<String, dynamic> map) =>
      CourseRegistrationRecord(
        regID: map['regID'] ?? '',
        studentID: map['studentID'] ?? '',
        sectID: map['sectID'] ?? '',
        sessionID: map['sessionID'] ?? '',
        totalSub: map['totalSub'] ?? 0,
        regStatus: map['regStatus'] ?? 'Registered',
        regAt: DateTime.tryParse(map['regAt'] ?? '') ?? DateTime.now(),
        subCode: map['subCode'] ?? '',
        subName: map['subName'] ?? '',
        creditHour: map['creditHour'] ?? 0,
        classType: map['classType'] ?? '',
        sectNo: map['sectNo'] ?? '',
        lectName: map['lectName'] ?? '',
        days: map['days'] ?? '',
        startTime: map['startTime'] ?? '',
        endTime: map['endTime'] ?? '',
        venue: map['venue'] ?? '',
        semester: map['semester'] ?? '',
      );
}
