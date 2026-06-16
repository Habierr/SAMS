import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Page/student/student_dashboard.dart';
import 'package:sams/Page/Attendance/attendanceList.dart';

/// Attendance Check-In Page
/// Displays all registered subjects for the logged-in student.
class AttendanceCheckIn extends StatelessWidget {
  final String studentName;
  final String studentId;

  const AttendanceCheckIn({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  /// Retrieve registered subjects from Firestore
  Future<List<Map<String, dynamic>>> getRegisteredSubjects() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Query registrations collection using student ID
    final regSnapshot = await db
        .collection('registrations')
        .where('studentID', isEqualTo: studentId)
        .get();

    // Store unique subjects only
    final Map<String, Map<String, dynamic>> uniqueCourses = {};

    for (var regDoc in regSnapshot.docs) {
      final regData = regDoc.data();

      // Get subject code
      final String subCode = (regData['subCode'] ?? '').toString();

      // Skip if subject code is empty
      if (subCode.isEmpty) continue;

      // Store subject information
      uniqueCourses[subCode] = {
        'code': subCode,
        'name': regData['subName'] ?? 'Subject Name',
      };
    }

    // Return list of registered subjects
    return uniqueCourses.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Background color of page
      backgroundColor: const Color(0xFFF5F7FA),

      // Navigation Drawer
      drawer: Drawer(
        child: Column(
          children: [

            // Drawer Header with UMPSA logo
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

                    // System title
                    const Text(
                      'STUDENT ACADEMIC\nMANAGEMENT',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Navigate back to Student Dashboard
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

            // Logout button
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
          ],
        ),
      ),

      // Application Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,

          // Open navigation drawer
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),

          // System title
          title: const Text(
            'STUDENT ACADEMIC\nMANAGEMENT',
            textAlign: TextAlign.center,
          ),

          centerTitle: true,

          // UMPSA logo
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

          // Gradient background
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

      // Main Content
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome message
            Text(
              'Welcome, $studentName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Section title
            const Center(
              child: Text(
                'My Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getRegisteredSubjects(),

                builder: (context, snapshot) {

                  // Show loading indicator while data is loading
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Display error message if retrieval fails
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading subjects: ${snapshot.error}',
                      ),
                    );
                  }

                  final courses = snapshot.data ?? [];

                  // Display message if no subjects found
                  if (courses.isEmpty) {
                    return const Center(
                      child: Text(
                        'No registered subjects found',
                      ),
                    );
                  }

                  // Display registered subjects in grid layout
                  return GridView.builder(
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

                        // Open attendance list of selected subject
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
                            borderRadius:
                                BorderRadius.circular(10),
                          ),

                          child: Column(
                            children: [

                              const SizedBox(height: 14),

                              // Subject icon
                              Image.asset(
                                'assets/books.png',
                                width: 70,
                                height: 70,

                                // Display default icon if image fails
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.menu_book_rounded,
                                    size: 65,
                                  );
                                },
                              ),

                              const SizedBox(height: 8),

                              // Subject code
                              Text(
                                course['code'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              // Subject name
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 4,
                                ),
                                child: Text(
                                  course['name'],
                                  textAlign: TextAlign.center,
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
