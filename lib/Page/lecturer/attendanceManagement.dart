import 'package:flutter/material.dart';
import 'package:sams/lecturer/lecturer_dashboard.dart';

class AttendanceManagement extends StatelessWidget {
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

  const AttendanceManagement({
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

  Map<String, dynamic> get _arguments => {
    'lecturerName': lecturerName,
    'lecturerId': lecturerId,
    'regID': regID,
    'subCode': subCode,
    'subName': subName,
    'classType': classType,
    'sectionNo': sectionNo,
    'day': day,
    'startTime': startTime,
    'endTime': endTime,
    'semester': semester,
  };

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
                  colors: [Color(0xFF2E9D13), Color(0xFF5CB835)],
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
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 35, 22, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Column(
          children: [
            Text(
              subCode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$subName | $classType ($sectionNo)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '$day, $startTime - $endTime | $semester',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 45),

            _menuButton(
              text: 'Create Class Code',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/generateClassCode',
                  arguments: _arguments,
                );
              },
            ),

            const SizedBox(height: 25),

            _menuButton(
              text: 'Class Code List',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/classCodeList',
                  arguments: _arguments,
                );
              },
            ),

            const SizedBox(height: 25),

            _menuButton(
              text: 'Student Attendance Record',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/attendanceRecord',
                  arguments: _arguments,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF1F5EE),
          foregroundColor: const Color(0xFF111B4D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}