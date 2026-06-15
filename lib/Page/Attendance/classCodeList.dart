import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Page/Attendance/lecturer_dashboard.dart';
import 'package:sams/Page/Attendance/attendanceReport.dart';

class ClassCodeList extends StatelessWidget {
  final String lecturerName;
  final String lecturerId;
  final String regID;
  final String subCode;
  final String subName;
  final String classType;
  final String sectionNo;
  final String day;
  final String startTime;
  final String endTime;
  final String semester;

  const ClassCodeList({
    super.key,
    required this.lecturerName,
    required this.lecturerId,
    required this.regID,
    required this.subCode,
    required this.subName,
    required this.classType,
    required this.sectionNo,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.semester,
  });

  void copyClassCode(BuildContext context, String code) {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No class code to copy')),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: code));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Class Code $code copied successfully!')),
    );
  }

  void openReport(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceReport(
          lecturerName: lecturerName,
          lecturerId: lecturerId,
          subCode: subCode,
          subName: subName,
          sessionDate: data['sessionDate'] ?? '',
          section: data['section'] ?? '',
          sessionTime: data['sessionTime'] ?? '',
          classSession: data['classSession'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2E9D13),
                    Color(0xFF5CB835),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo_umpsa.png', width: 55),
                    const SizedBox(height: 10),
                    const Text(
                      'STUDENT ACADEMIC\nMANAGEMENT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LecturerDashboard(
                      lecturerName: lecturerName,
                      lecturerId: lecturerId,
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 26),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
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
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Class Code List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111B4D),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$subName | $classType ($sectionNo)',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$day, $startTime - $endTime | $semester',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('classCode')
                    .where('lecturerID', isEqualTo: lecturerId)
                    .where('regID', isEqualTo: regID)
                    .where('subCode', isEqualTo: subCode)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading class codes:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final classCodes = snapshot.data?.docs ?? [];

                  if (classCodes.isEmpty) {
                    return const Center(child: Text('No class code found'));
                  }

                  return ListView.builder(
                    itemCount: classCodes.length,
                    itemBuilder: (context, index) {
                      final doc = classCodes[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final classCode = data['generatedCode'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5EE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoText('Date', data['sessionDate'] ?? ''),
                            _infoText('Section', data['section'] ?? ''),
                            _infoText(
                              'Class Time',
                              data['sessionTime'] ?? '',
                            ),
                            _infoText(
                              'Session',
                              data['classSession'] ?? '',
                            ),
                            _infoText('Class Code', classCode),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5A00D6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  copyClassCode(context, classCode);
                                },
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text(
                                  'Copy Class Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E9D13),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  openReport(context, data);
                                },
                                icon: const Icon(
                                  Icons.picture_as_pdf,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'View Attendance Report',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _showUpdateDialog(context, doc.id, data);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    _showDeleteDialog(context, doc.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 35, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you confirm to\ndelete this attendance\nclass code ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF111B4D),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('classCode')
                            .doc(docId)
                            .delete();

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdateDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    String displayDate = data['sessionDate'] ?? '';
    String classCode = data['generatedCode'] ?? '';

    final fixedSection = data['section'] ?? sectionNo;
    final fixedSession = data['classSession'] ?? classType;
    final fixedStartTime = data['startTime'] ?? startTime;
    final fixedEndTime = data['endTime'] ?? endTime;
    final fixedSessionTime = '$fixedStartTime - $fixedEndTime';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDate() async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );

              if (date != null) {
                setDialogState(() {
                  displayDate = '${date.day}/${date.month}/${date.year}';
                });
              }
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Update Class Code',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111B4D),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        '$subCode\n$subName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111B4D),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const SizedBox(
                            width: 95,
                            child: Text(
                              'Date:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111B4D),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: pickDate,
                              child: _popupBox(
                                displayDate,
                                icon: Icons.keyboard_arrow_down,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const SizedBox(
                            width: 95,
                            child: Text(
                              'Section:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111B4D),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _popupBox(fixedSection),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const SizedBox(
                            width: 95,
                            child: Text(
                              'Class Time:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111B4D),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _popupBox(fixedSessionTime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const SizedBox(
                            width: 95,
                            child: Text(
                              'Session:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111B4D),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _popupBox(fixedSession),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const SizedBox(
                            width: 95,
                            child: Text(
                              'Class Code:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111B4D),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                copyClassCode(context, classCode);
                              },
                              child: _popupBox(classCode),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: Color(0xFF5A00D6),
                              size: 20,
                            ),
                            onPressed: () {
                              copyClassCode(context, classCode);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: 120,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A00D6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            if (displayDate.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select date'),
                                ),
                              );
                              return;
                            }

                            await FirebaseFirestore.instance
                                .collection('classCode')
                                .doc(docId)
                                .update({
                              'regID': regID,
                              'subCode': subCode,
                              'subName': subName,
                              'classType': classType,
                              'section': fixedSection,
                              'classSession': fixedSession,
                              'sessionDate': displayDate,
                              'startTime': fixedStartTime,
                              'endTime': fixedEndTime,
                              'sessionTime': fixedSessionTime,
                              'lecturerID': lecturerId,
                              'lecturerName': lecturerName,
                              'semester': semester,
                            });

                            Navigator.pop(context);
                            _showSuccessDialog(context);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _popupBox(String text, {IconData? icon}) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: icon == null
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF111B4D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (icon != null) Icon(icon, color: Colors.black),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            width: 230,
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF8EF5A4),
                        Color(0xFF18B957),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Class code update\nsuccessfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF111B4D),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 120,
                  height: 34,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A00D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Okay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
