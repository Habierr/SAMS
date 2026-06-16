import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Page/Attendance/lecturer_dashboard.dart';
import 'package:sams/Page/Attendance/summaryRecord.dart';

class AttendanceRecord extends StatefulWidget {
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

  const AttendanceRecord({
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

  @override
  State<AttendanceRecord> createState() => _AttendanceRecordState();
}

class _AttendanceRecordState extends State<AttendanceRecord> {
  DateTime? selectedDate;

  late String selectedSession;
  late String selectedSection;

  @override
  void initState() {
    super.initState();
    selectedSession = widget.classType;
    selectedSection = widget.sectionNo;
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> pickDate() async {
    // Open date picker for attendance record search
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> generateRecord() async {
    if (selectedDate == null) {
      showNoRecordPopup();
      return;
    }

    final dateText = formatDate(selectedDate!);
    final timeText = '${widget.startTime} - ${widget.endTime}';

    final classCodeResult = await FirebaseFirestore.instance
        .collection('classCode')
        .where('regID', isEqualTo: widget.regID)
        .where('subCode', isEqualTo: widget.subCode)
        .where('sessionDate', isEqualTo: dateText)
        .where('section', isEqualTo: selectedSection)
        .where('sessionTime', isEqualTo: timeText)
        .where('classSession', isEqualTo: selectedSession)
        .get();

    // Check whether attendance record exists
    if (classCodeResult.docs.isEmpty) {
      showNoRecordPopup();
      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryRecord(
          lecturerName: widget.lecturerName,
          lecturerId: widget.lecturerId,
          regID: widget.regID,
          subCode: widget.subCode,
          subName: widget.subName,
          classType: widget.classType,
          sectionNo: widget.sectionNo,
          semester: widget.semester,
          sessionDate: dateText,
          section: selectedSection,
          sessionTime: timeText,
          classSession: selectedSession,
        ),
      ),
    );
  }

  void showNoRecordPopup() {
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
                    color: Color(0xFFE91E63),
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No attendance record\navailable',
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Okay',
                      style: TextStyle(color: Colors.white),
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

  Widget inputBox(String text, VoidCallback onTap, {IconData? icon}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111B4D),
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget fixedBox(String text) {
    return Expanded(
      child: Container(
        height: 35,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111B4D),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null ? '' : formatDate(selectedDate!);
    final timeText = '${widget.startTime} - ${widget.endTime}';

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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                      lecturerName: widget.lecturerName,
                      lecturerId: widget.lecturerId,
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
              onPressed: () => Scaffold.of(context).openDrawer(),
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
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 35, 18, 20),
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
              'Attendance Record',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.subCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.subName} | ${widget.classType} (${widget.sectionNo})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.day}, ${widget.startTime} - ${widget.endTime} | ${widget.semester}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
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
                inputBox(
                  dateText,
                  pickDate,
                  icon: Icons.keyboard_arrow_down,
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
                fixedBox(widget.sectionNo),
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
                fixedBox(timeText),
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
                fixedBox(widget.classType),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A00D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: generateRecord,
                child: const Text(
                  'Generate Record',
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
  }
}
