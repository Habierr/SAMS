import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerDashboard extends StatelessWidget {
  final String lecturerName;
  final String lecturerId;

  const LecturerDashboard({
    super.key,
    required this.lecturerName,
    required this.lecturerId,
  });
  
// Lecturer dashboard interface
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
                Navigator.pop(context);
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
        padding: const EdgeInsets.fromLTRB(18, 30, 18, 20),
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
              'Welcome, $lecturerName',
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
            // Load lecturer course registrations from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('registrations')
                    .where('lectName', isEqualTo: lecturerName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading courses:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final registrations = snapshot.data?.docs ?? [];

                  if (registrations.isEmpty) {
                    return const Center(
                      child: Text(
                        'No courses found for this lecturer',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: registrations.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 26,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final data =
                          registrations[index].data() as Map<String, dynamic>;

                      final regID = data['regID'] ?? registrations[index].id;

                      final classType = data['classType'] ?? 'Class';
                      final sectionNo = data['sectNo'] ?? '-';
                      final day = data['days'] ?? '-';
                      final startTime = data['startTime'] ?? '-';
                      final endTime = data['endTime'] ?? '-';
                      final semester = data['semester'] ?? '-';

                      final subCode = data['subCode'] ??
                          data['subjectCode'] ??
                          data['courseCode'] ??
                          regID;

                      final subName = data['subName'] ??
                          data['subjectName'] ??
                          '$classType ($sectionNo)';

                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/attendanceManagement',
                            arguments: {
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
                            },
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
                              const SizedBox(height: 12),
                              Image.asset(
                                'assets/books.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.menu_book_rounded,
                                    size: 60,
                                    color: Colors.blue,
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subCode.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111B4D),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 4,
                                ),
                                color: const Color(0xFFE6EDF9),
                                child: Text(
                                  subName.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.1,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF111B4D),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Day: $day',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111B4D),
                                ),
                              ),
                              Text(
                                'Time: $startTime - $endTime',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111B4D),
                                ),
                              ),
                              Text(
                                'Semester: $semester',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111B4D),
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
