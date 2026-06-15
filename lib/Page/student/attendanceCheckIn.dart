import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Page/student/student_dashboard.dart';
import 'package:sams/Page/student/attendanceList.dart';

class AttendanceCheckIn extends StatelessWidget {
  final String studentName;
  final String studentId;

  const AttendanceCheckIn({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  Future<List<Map<String, dynamic>>> getRegisteredSubjects() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final regSnapshot = await db
        .collection('registrations')
        .where('studentID', isEqualTo: studentId)
        .get();

    final Map<String, Map<String, dynamic>> uniqueCourses = {};

    for (var regDoc in regSnapshot.docs) {
      final regData = regDoc.data();

      final String subCode = (regData['subCode'] ?? '').toString();
      if (subCode.isEmpty) continue;

      uniqueCourses[subCode] = {
        'code': subCode,
        'name': regData['subName'] ?? 'Subject Name',
      };
    }

    return uniqueCourses.values.toList();
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
                    Color(0xFF11A06E),
                    Color(0xFF48C598),
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
                    builder: (context) => StudentDashboard(
                      studentName: studentName,
                      studentID: studentId,
                      year: 'Year 3',
                      semester: 'Sem 2 2025/2026',
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
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 26,
              ),
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
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $studentName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'My Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111B4D),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getRegisteredSubjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading subjects: ${snapshot.error}'),
                    );
                  }

                  final courses = snapshot.data ?? [];

                  if (courses.isEmpty) {
                    return const Center(
                      child: Text('No registered subjects found'),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: courses.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 26,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final course = courses[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceList(
                                studentName: studentName,
                                studentId: studentId,
                                subCode: course['code'],
                                subName: course['name'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5EE),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF7C4DFF).withOpacity(0.18),
                                blurRadius: 7,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 14),
                              Image.asset(
                                'assets/books.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.menu_book_rounded,
                                    size: 65,
                                    color: Colors.blue,
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course['code'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111B4D),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 4,
                                ),
                                color: const Color(0xFFE6EDF9),
                                child: Text(
                                  course['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.1,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111B4D),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
}
