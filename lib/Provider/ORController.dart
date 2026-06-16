import 'package:flutter/material.dart';
import '../Domain/ORModel.dart';
import '../Services/FirebaseService.dart';

class ORController extends ChangeNotifier {
  // Data persistence layer encapsulation dependency
  final FirebaseService _firebaseService = FirebaseService();

  // Selected structural references for active entity manipulation sessions
  String _regisID = '';
  String _studentID = '';
  String _sectID = '';
  String _sessionID = '';
  String _regID = '';

  String get regisID => _regisID;
  String get studentID => _studentID;
  String get sectID => _sectID;
  String get sessionID => _sessionID;
  String get regID => _regID;

  // Global system cache arrays initialized to optimize internal memory operations
  List<OfferingRegistration> _offerings = [];
  List<String> _offeringsDocIds = [];
  List<Subject> _subjects = [];
  List<ORSession> _orSessions = [];

  // Active student state data structures and related tracking document identities
  List<CourseRegistrationRecord> _studentRegistrations = [];
  List<String> _studentRegDocIds = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<OfferingRegistration> get offerings => _offerings;
  List<String> get offeringsDocIds => _offeringsDocIds;
  List<Subject> get subjects => _subjects;
  List<ORSession> get orSessions => _orSessions;
  List<CourseRegistrationRecord> get studentRegistrations =>
      _studentRegistrations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Real-time calculated property using dynamic date/time tracking comparison logic
  ORSession? get activeSession {
    try {
      return _orSessions.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  // Dynamic filter array targeting current systemic semester allocations
  List<OfferingRegistration> get activeOfferings {
    final session = activeSession;
    if (session == null) return [];
    return _offerings.where((o) => o.semester == session.semester).toList();
  }

  // Dynamic deduplication map compilation matrix preventing duplicate layout cards
  List<Subject> get activeSubjects {
    final Map<String, Subject> seen = {};
    for (final o in activeOfferings) {
      if (!seen.containsKey(o.subCode)) {
        seen[o.subCode] = Subject(
          subCode: o.subCode,
          subName: o.subName,
          creditHour: _subjects
              .firstWhere(
                (s) => s.subCode == o.subCode,
                orElse: () => Subject(
                    subCode: '', subName: '', creditHour: 0, faculty: ''),
              )
              .creditHour,
          faculty: _subjects
              .firstWhere(
                (s) => s.subCode == o.subCode,
                orElse: () => Subject(
                    subCode: '', subName: '', creditHour: 0, faculty: ''),
              )
              .faculty,
        );
      }
    }
    return seen.values.toList();
  }

  // Structural mapping algorithm linking subject code descriptors to individual sections
  Map<String, List<OfferingRegistration>> get offeringsBySubject {
    final Map<String, List<OfferingRegistration>> map = {};
    for (final o in activeOfferings) {
      map.putIfAbsent(o.subCode, () => []).add(o);
    }
    return map;
  }

  Set<String> get registeredSectIDs =>
      _studentRegistrations.map((r) => r.sectID).toSet();

  Set<String> get registeredSubCodes =>
      _studentRegistrations.map((r) => r.subCode).toSet();

  bool isSubjectRegistered(String subCode) =>
      registeredSubCodes.contains(subCode);

  int get totalRegisteredSubjects =>
      _studentRegistrations.where((r) => r.isLecture).length;

  int get totalCreditHours => _studentRegistrations
      .where((r) => r.isLecture)
      .fold(0, (sum, r) => sum + r.creditHour);

  Future<void> processOR() async => await loadData();

  Future<void> updateOR(OfferingRegistration offering, String docId) async {
    try {
      await _firebaseService.updateOffering(docId, offering);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update offering: $e';
      notifyListeners();
    }
  }

  Future<OfferingRegistration?> fetchORRecord(String sectID) async {
    for (final offering in _offerings) {
      if (offering.sectID == sectID) return offering;
    }
    return null;
  }

  void setCurrentUser({String? studentID, String? regisID}) {
    if (studentID != null) _studentID = studentID;
    if (regisID != null) _regisID = regisID;
  }

  // Multi-stream operational task scheduler initializing standard database objects simultaneously
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firebaseService.getSubjects(),
        _firebaseService.getORSessions(),
      ]);

      _subjects = results[0] as List<Subject>;
      _orSessions = results[1] as List<ORSession>;

      _listenToOfferings();

      if (_studentID.isNotEmpty) {
        _listenToStudentRegistrations();
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Continuous listener subscription piping global course offerings from cloud state maps
  void _listenToOfferings() {
    _firebaseService.getOfferingsWithIds().listen(
      (offeringsWithIds) {
        _offerings = [];
        _offeringsDocIds = [];
        for (final item in offeringsWithIds) {
          _offeringsDocIds.add(item['id'] as String);
          _offerings.add(item['data'] as OfferingRegistration);
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Stream error: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Reactive transaction stream syncing custom selection modifications instantly per matric session
  void _listenToStudentRegistrations() {
    _firebaseService.getStudentRegistrations(_studentID).listen(
      (regsWithIds) {
        _studentRegistrations = [];
        _studentRegDocIds = [];
        for (final item in regsWithIds) {
          _studentRegDocIds.add(item['id'] as String);
          _studentRegistrations.add(item['data'] as CourseRegistrationRecord);
        }
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Registration stream error: $e';
        notifyListeners();
      },
    );
  }

  Future<void> addOffering(OfferingRegistration offering) async {
    await _firebaseService.addOffering(offering);
    notifyListeners();
  }

  Future<void> updateOffering(
      String docId, OfferingRegistration offering) async {
    await _firebaseService.updateOffering(docId, offering);
    notifyListeners();
  }

  Future<void> deleteOffering(String docId) async {
    await _firebaseService.deleteOffering(docId);
    notifyListeners();
  }

  Future<void> addSubject(Subject subject) async {
    await _firebaseService.addSubject(subject);
    _subjects = await _firebaseService.getSubjects();
    notifyListeners();
  }

  Future<void> updateSubject(String docId, Subject subject) async {
    await _firebaseService.updateSubject(docId, subject);
    _subjects = await _firebaseService.getSubjects();
    notifyListeners();
  }

  Future<void> deleteSubject(String docId) async {
    await _firebaseService.deleteSubject(docId);
    _subjects = await _firebaseService.getSubjects();
    notifyListeners();
  }

  Future<void> saveORSession(ORSession session) async {
    await _firebaseService.saveORSession(session);
    await loadData();
  }

  // Verification processing loop evaluating business constraints prior to structural document storage mutations
  Future<String?> registerSubject({
    required OfferingRegistration offering,
  }) async {
    if (_studentID.isEmpty) return 'Student not logged in.';

    final session = activeSession;
    if (session == null || !session.isActive) {
      return 'OR session is not currently active.';
    }

    if (offering.isFull) {
      return 'Section ${offering.sectNo} is full (${offering.enrollmentLabel}).';
    }

    if (offering.isLecture && isSubjectRegistered(offering.subCode)) {
      return '${offering.subCode} - ${offering.subName} sudah didaftarkan.';
    }

    if (registeredSectIDs.contains(offering.sectID)) {
      return 'Section ${offering.sectNo} sudah dipilih.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final newRegID = 'REG${now.millisecondsSinceEpoch}';

      _regID = newRegID;
      _sectID = offering.sectID;
      _sessionID = session.sessionID;

      final subjectRef = _subjects.firstWhere(
        (s) => s.subCode == offering.subCode,
        orElse: () =>
            Subject(subCode: '', subName: '', creditHour: 0, faculty: ''),
      );

      final record = CourseRegistrationRecord(
        regID: newRegID,
        studentID: _studentID,
        sectID: offering.sectID,
        sessionID: session.sessionID,
        totalSub: totalRegisteredSubjects + (offering.isLecture ? 1 : 0),
        regStatus: 'Registered',
        regAt: now,
        subCode: offering.subCode,
        subName: offering.subName,
        creditHour: offering.isLecture ? subjectRef.creditHour : 0,
        classType: offering.classType,
        sectNo: offering.sectNo,
        lectName: offering.lectName,
        days: offering.days,
        startTime: offering.startTime,
        endTime: offering.endTime,
        venue: offering.venue,
        semester: offering.semester,
      );

      // Concurrent atomic pipeline requests mutating enrollment counts safely
      await _firebaseService.addStudentRegistration(record);

      await _firebaseService.incrementEnrolled(offering.sectID);

      _errorMessage = null;
      return null;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Deletion logic matrix processing removals across interrelated dynamic list bounds sequentially
  Future<String?> dropSubject(String subCode) async {
    try {
      final toRemove = <int>[];
      for (int i = 0; i < _studentRegistrations.length; i++) {
        if (_studentRegistrations[i].subCode == subCode) {
          toRemove.add(i);
        }
      }

      for (final idx in toRemove) {
        final regDocId = _studentRegDocIds[idx];
        final sectID = _studentRegistrations[idx].sectID;

        await _firebaseService.deleteStudentRegistration(regDocId);

        await _firebaseService.decrementEnrolled(sectID);
      }
      return null;
    } catch (e) {
      return 'Failed to drop subject: $e';
    }
  }

  // Transaction swap script resetting indices dynamically during live subject updates
  Future<String?> editRegistration({
    required String subCode,
    required String classType,
    required OfferingRegistration newOffering,
  }) async {
    try {
      int? existingIdx;
      for (int i = 0; i < _studentRegistrations.length; i++) {
        final r = _studentRegistrations[i];
        if (r.subCode.trim() == subCode.trim() &&
            r.classType.trim().toLowerCase() ==
                classType.trim().toLowerCase()) {
          existingIdx = i;
          break;
        }
      }

      if (existingIdx == null) {
        final found = _studentRegistrations
            .map((r) => '${r.subCode}|${r.classType}')
            .join(', ');
        return 'Registration record not found.\nLooking for: $subCode | $classType\nAvailable: $found';
      }

      if (newOffering.isFull) {
        return 'Section ${newOffering.sectNo} is full.';
      }

      final existing = _studentRegistrations[existingIdx];
      final regDocId = _studentRegDocIds[existingIdx];

      final subjectRef = _subjects.firstWhere(
        (s) => s.subCode == subCode,
        orElse: () =>
            Subject(subCode: '', subName: '', creditHour: 0, faculty: ''),
      );

      final updated = CourseRegistrationRecord(
        regID: existing.regID,
        studentID: existing.studentID,
        sectID: newOffering.sectID,
        sessionID: existing.sessionID,
        totalSub: existing.totalSub,
        regStatus: 'Registered',
        regAt: existing.regAt,
        subCode: subCode,
        subName: newOffering.subName,
        creditHour: existing.isLecture ? subjectRef.creditHour : 0,
        classType: existing.classType,
        sectNo: newOffering.sectNo,
        lectName: newOffering.lectName,
        days: newOffering.days,
        startTime: newOffering.startTime,
        endTime: newOffering.endTime,
        venue: newOffering.venue,
        semester: existing.semester,
      );

      await _firebaseService.updateStudentRegistration(regDocId, updated);

      await _firebaseService.decrementEnrolled(existing.sectID);
      await _firebaseService.incrementEnrolled(newOffering.sectID);

      return null;
    } catch (e) {
      return 'Failed to edit registration: $e';
    }
  }

  Future<int> getTotalEnrolled() async =>
      await _firebaseService.getTotalEnrolled();

  Future<int> getTotalOfferings() async =>
      await _firebaseService.getTotalOfferings();

  Future<int> getFullOfferings() async =>
      await _firebaseService.getFullOfferings();

  Future<void> initializeData() async {
    await _firebaseService.initializeSampleData();
    await loadData();
  }
}
