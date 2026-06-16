import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Domain/SAMSAttendanceModel.dart';

class SAMSAttendanceController {
  // Firestore database instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Retrieve registered subjects for a student
  Future<List<Map<String, dynamic>>> getRegisteredSubjects(
    String studentID,
  ) async {
    final snapshot = await _db
        .collection('registrations')
        .where('studentID', isEqualTo: studentID)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Retrieve class code details
  Future<Map<String, dynamic>?> getClassCode(
    String generatedCode,
  ) async {
    final doc = await _db.collection('classCode').doc(generatedCode).get();

    if (!doc.exists) return null;

    return doc.data();
  }

  // Save attendance record into Firestore
  Future<void> submitAttendance(
    SAMSAttendanceModel attendance,
  ) async {
    await _db
        .collection('attendance')
        .doc(attendance.attendanceID)
        .set(attendance.toMap());
  }

  // Retrieve attendance records for a specific subject
  Stream<QuerySnapshot> getAttendanceList(
    String studentID,
    String subCode,
  ) {
    return _db
        .collection('attendance')
        .where('studentID', isEqualTo: studentID)
        .where('subCode', isEqualTo: subCode)
        .snapshots();
  }

  // Generate and store a new class code
  Future<void> generateClassCode(
    Map<String, dynamic> classCodeData,
  ) async {
    await _db
        .collection('classCode')
        .doc(classCodeData['generatedCode'])
        .set(classCodeData);
  }

  // Update existing class code information
  Future<void> updateClassCode(
    String classCodeID,
    Map<String, dynamic> updatedData,
  ) async {
    await _db.collection('classCode').doc(classCodeID).update(updatedData);
  }

  // Delete class code from Firestore
  Future<void> deleteClassCode(
    String classCodeID,
  ) async {
    await _db.collection('classCode').doc(classCodeID).delete();
  }

  // Retrieve attendance report records
  Stream<QuerySnapshot> getAttendanceReport(
    String subCode,
  ) {
    return _db
        .collection('attendance')
        .where('subCode', isEqualTo: subCode)
        .snapshots();
  }
}
