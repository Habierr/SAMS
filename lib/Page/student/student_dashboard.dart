import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Page/student/attendanceCheckIn.dart';

class StudentDashboard extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String year;
  final String semester;

  const StudentDashboard({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.year,
    required this.semester,
  });

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'S';
  }

  Future<Map<String, dynamic>> getRegistrationSummary() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .where('studentID', isEqualTo: studentId)
        .get();

    final uniqueSubjects = <String>{};
    int totalCreditHour = 0;
    String displayYear = year;
    String displaySemester = semester;
    String status = 'Inactive';

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final subCode = (data['subCode'] ?? '').toString();
      if (subCode.isNotEmpty) {
        uniqueSubjects.add(subCode);
      }

      final credit = data['creditHour'] ?? 0;
      if (credit is int) {
        totalCreditHour += credit;
      } else {
        totalCreditHour += int.tryParse(credit.toString()) ?? 0;
      }

      if ((data['semester'] ?? '').toString().isNotEmpty) {
        displaySemester = data['semester'].toString();
      }

      final sessionID = (data['sessionID'] ?? '').toString();
      if (sessionID.contains('Year')) {
        final parts = sessionID.split('-');
        if (parts.isNotEmpty) {
          displayYear = parts.first.replaceAll('SES-', '');
        }
      }

      if ((data['regStatus'] ?? '').toString() == 'Registered') {
        status = 'Active';
      }
    }

    return {
      'subjects': uniqueSubjects.length,
      'creditHour': totalCreditHour,
      'year': displayYear,
      'semester': displaySemester,
      'status': status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final initials = getInitials(studentName);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF11A06E),
                    Color(0xFF48C598),
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
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('My Courses'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceCheckIn(
                      studentName: studentName,
                      studentId: studentId,
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
        preferredSize: const Size.fromHeight(80),
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
                  Color(0xFF11A06E),
                  Color(0xFF48C598),
                  Color(0xFF88E5BE),
                ],
              ),
            ),
          ),
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: getRegistrationSummary(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? {};

          final subjectCount = data['subjects'] ?? 0;
          final creditHour = data['creditHour'] ?? 0;
          final displayYear = data['year'] ?? year;
          final displaySemester = data['semester'] ?? semester;
          final status = data['status'] ?? 'Inactive';

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFD4F0C8),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Color(0xFF55A630),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('$studentId - $displayYear'),
                            Text(
                              displaySemester,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 62,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFDDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                                    ? '-'
                                    : subjectCount.toString(),
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Subjects'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          height: 62,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7EFC5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                                    ? '-'
                                    : creditHour.toString(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Credit hours'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OR session',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: status == 'Active'
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text('Semester: $displaySemester'),
                        const SizedBox(height: 10),
                        Center(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceCheckIn(
                                    studentName: studentName,
                                    studentId: studentId,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Registered course'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Course Registration'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AttendanceCheckIn(
                                        studentName: studentName,
                                        studentId: studentId,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('My Courses'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Co-curriculum'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Finance'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
