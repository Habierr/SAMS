import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Domain/SAMSAttendanceModel.dart';

class SAMSAttendanceController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getRegisteredSubjects(
      String studentID,
      ) async {
    final snapshot = await _db
        .collection('registrations')
        .where('studentID', isEqualTo: studentID)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>?> getClassCode(
      String generatedCode,
      ) async {
    final doc = await _db.collection('classCode').doc(generatedCode).get();

    if (!doc.exists) return null;

    return doc.data();
  }

  Future<void> submitAttendance(
      SAMSAttendanceModel attendance,
      ) async {
    await _db
        .collection('attendance')
        .doc(attendance.attendanceID)
        .set(attendance.toMap());
  }

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

  Future<void> generateClassCode(
      Map<String, dynamic> classCodeData,
      ) async {
    await _db
        .collection('classCode')
        .doc(classCodeData['generatedCode'])
        .set(classCodeData);
  }

  Future<void> updateClassCode(
      String classCodeID,
      Map<String, dynamic> updatedData,
      ) async {
    await _db.collection('classCode').doc(classCodeID).update(updatedData);
  }

  Future<void> deleteClassCode(
      String classCodeID,
      ) async {
    await _db.collection('classCode').doc(classCodeID).delete();
  }

  Stream<QuerySnapshot> getAttendanceReport(
      String subCode,
      ) {
    return _db
        .collection('attendance')
        .where('subCode', isEqualTo: subCode)
        .snapshots();
  }
}