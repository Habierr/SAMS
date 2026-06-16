import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Page/Attendance/attendanceReport.dart';

// Lecturer, class and attendance session information
class SummaryRecord extends StatefulWidget {
  final String lecturerName;
  final String lecturerId;

  final String regID;
  final String subCode;
  final String subName;
  final String classType;
  final String sectionNo;
  final String semester;

  final String sessionDate;
  final String section;
  final String sessionTime;
  final String classSession;

  const SummaryRecord({
    super.key,
    required this.lecturerName,
    required this.lecturerId,
    required this.regID,
    required this.subCode,
    required this.subName,
    required this.classType,
    required this.sectionNo,
    required this.semester,
    required this.sessionDate,
    required this.section,
    required this.sessionTime,
    required this.classSession,
  });

  @override
  State<SummaryRecord> createState() => _SummaryRecordState();
}

// Generate absent student records once when page loads
class _SummaryRecordState extends State<SummaryRecord> {
  late Future<void> _generateAbsentFuture;

  @override
  void initState() {
    super.initState();
    // Automatically create absent records
    _generateAbsentFuture = generateAbsentStudents();
  }

  Future<String> generateAttendanceId() async {
    final counterRef =
        FirebaseFirestore.instance.collection('counters').doc('attendance');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentNumber = 0;

      if (snapshot.exists) {
        currentNumber = snapshot.data()?['lastNumber'] ?? 0;
      }

      final nextNumber = currentNumber + 1;

      transaction.set(
        counterRef,
        {'lastNumber': nextNumber},
        SetOptions(merge: true),
      );

      return 'Att${nextNumber.toString().padLeft(3, '0')}';
    });
  }

  Future<String> getStudentName(String studentId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      return data['name'] ??
          data['studentName'] ??
          data['fullName'] ??
          data['studName'] ??
          '';
    }

    return '';
  }

  Future<String> getClassCode() async {
    final classCodeSnapshot = await FirebaseFirestore.instance
        .collection('classCode')
        .where('regID', isEqualTo: widget.regID)
        .where('subCode', isEqualTo: widget.subCode)
        .where('section', isEqualTo: widget.section)
        .where('sessionDate', isEqualTo: widget.sessionDate)
        .where('sessionTime', isEqualTo: widget.sessionTime)
        .where('classSession', isEqualTo: widget.classSession)
        .limit(1)
        .get();

    if (classCodeSnapshot.docs.isNotEmpty) {
      final data = classCodeSnapshot.docs.first.data();
      return data['generatedCode'] ?? '';
    }

    return '';
  }

  Future<void> generateAbsentStudents() async {
    final db = FirebaseFirestore.instance;
    final classCode = await getClassCode();

    final registrationSnapshot = await db
        .collection('registrations')
        .where('regID', isEqualTo: widget.regID)
        .where('lectName', isEqualTo: widget.lecturerName)
        .where('classType', isEqualTo: widget.classSession)
        .where('sectNo', isEqualTo: widget.section)
        .where('regStatus', isEqualTo: 'Registered')
        .get();

    final processedStudentIds = <String>{};

    for (var regDoc in registrationSnapshot.docs) {
      final regData = regDoc.data();

      final studentId = (regData['studentID'] ??
              regData['studID'] ??
              regData['studentId'] ??
              regData['userID'] ??
              '')
          .toString();

      if (studentId.isEmpty) continue;

      if (processedStudentIds.contains(studentId)) continue;
      processedStudentIds.add(studentId);

      final existingAttendance = await db
          .collection('attendance')
          .where('studentID', isEqualTo: studentId)
          .where('regID', isEqualTo: widget.regID)
          .where('subCode', isEqualTo: widget.subCode)
          .where('section', isEqualTo: widget.section)
          .where('sessionDate', isEqualTo: widget.sessionDate)
          .where('sessionTime', isEqualTo: widget.sessionTime)
          .where('classSession', isEqualTo: widget.classSession)
          .limit(1)
          .get();

      if (existingAttendance.docs.isNotEmpty) continue;

      final attendanceId = await generateAttendanceId();
      final studentName = await getStudentName(studentId);

      // Check whether attendance record already exists
      await db.collection('attendance').doc(attendanceId).set({
        'attendanceID': attendanceId,
        'studentID': studentId,
        'studentName': studentName,
        'regID': widget.regID,
        'subCode': widget.subCode,
        'subName': widget.subName,
        'classType': widget.classType,
        'section': widget.section,
        'classSession': widget.classSession,
        'classCode': classCode,
        'sessionDate': widget.sessionDate,
        'sessionTime': widget.sessionTime,
        'semester': widget.semester,
        'location': '',
        'attendanceStatus': 'Absent',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> generateReport(
    BuildContext context,
    List<QueryDocumentSnapshot> records,
  ) async {
    final totalStudent = records.length;

    final totalPresent = records.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['attendanceStatus'] == 'Present';
    }).length;

    final totalAbsent = records.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['attendanceStatus'] == 'Absent';
    }).length;

    final now = DateTime.now();
    final reportDate = '${now.day}/${now.month}/${now.year}';

    final snapshot = await FirebaseFirestore.instance
        .collection('attendanceReport')
        .orderBy('reportID', descending: true)
        .limit(1)
        .get();

    int nextNumber = 1;

    if (snapshot.docs.isNotEmpty) {
      final lastId = snapshot.docs.first['reportID'].toString();
      final number = int.tryParse(lastId.replaceAll('REPORT', '')) ?? 0;
      nextNumber = number + 1;
    }

    final reportID = 'REPORT${nextNumber.toString().padLeft(3, '0')}';

    await FirebaseFirestore.instance
        .collection('attendanceReport')
        .doc(reportID)
        .set({
      'reportID': reportID,
      'regID': widget.regID,
      'subCode': widget.subCode,
      'subName': widget.subName,
      'classType': widget.classType,
      'classSession': widget.classSession,
      'sessionDate': widget.sessionDate,
      'sessionTime': widget.sessionTime,
      'section': widget.section,
      'semester': widget.semester,
      'totalStudent': totalStudent,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'reportDate': reportDate,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceReport(
          lecturerName: widget.lecturerName,
          lecturerId: widget.lecturerId,
          subCode: widget.subCode,
          subName: widget.subName,
          sessionDate: widget.sessionDate,
          section: widget.section,
          sessionTime: widget.sessionTime,
          classSession: widget.classSession,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceQuery = FirebaseFirestore.instance
        .collection('attendance')
        .where('regID', isEqualTo: widget.regID)
        .where('subCode', isEqualTo: widget.subCode)
        .where('section', isEqualTo: widget.section)
        .where('sessionDate', isEqualTo: widget.sessionDate)
        .where('sessionTime', isEqualTo: widget.sessionTime)
        .where('classSession', isEqualTo: widget.classSession);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'STUDENT ACADEMIC\nMANAGEMENT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                'assets/logo_umpsa.png',
                width: 45,
                height: 45,
              ),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2E9D13),
                  Color(0xFF5CB835),
                  Color(0xFF92DC5E),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 30, 18, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: FutureBuilder<void>(
          future: _generateAbsentFuture,
          builder: (context, absentSnapshot) {
            if (absentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (absentSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error generating absent records:\n${absentSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: attendanceQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading attendance records:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = snapshot.data?.docs ?? [];

                if (records.isEmpty) {
                  return const Center(
                    child: Text('No attendance record available'),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Attendance Record',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111B4D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.subCode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111B4D),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.subName} | ${widget.classSession} (${widget.section})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5EE),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailText('Date', widget.sessionDate),
                            _detailText('Section', widget.section),
                            _detailText('Class Time', widget.sessionTime),
                            _detailText('Session', widget.classSession),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Attendance List',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111B4D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Table(
                        border: TableBorder.all(color: Colors.black87),
                        columnWidths: const {
                          0: FlexColumnWidth(1.25),
                          1: FlexColumnWidth(1.9),
                          2: FlexColumnWidth(1.1),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                              color: Color(0xFFF1F5EE),
                            ),
                            children: [
                              _TableCell('Student ID', bold: true),
                              _TableCell('Student Name', bold: true),
                              _TableCell('Status', bold: true),
                            ],
                          ),
                          ...records.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final status = data['attendanceStatus'] ?? '';

                            return TableRow(
                              children: [
                                _TableCell(data['studentID'] ?? ''),
                                _TableCell(data['studentName'] ?? ''),
                                _TableCell(
                                  status,
                                  color: status == 'Absent'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A00D6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            generateReport(context, records);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Generate Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _detailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;

  const _TableCell(
    this.text, {
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: color ?? Colors.black,
        ),
      ),
    );
  }
}
