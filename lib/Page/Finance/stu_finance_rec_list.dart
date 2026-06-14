import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'treasury_stu_ledger.dart';

class StudentFinanceRecordsList extends StatefulWidget {
  const StudentFinanceRecordsList({super.key});

  @override
  State<StudentFinanceRecordsList> createState() =>
      _StudentFinanceRecordsListState();
}

class _StudentFinanceRecordsListState extends State<StudentFinanceRecordsList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Listen to changes in the search bar to dynamically refresh the list
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toUpperCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // 1. Treasury Styled AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // Makes back arrow white
          title: const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'STUDENT ACADEMIC\nMANAGEMENT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/logo_umpsa.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF988B0C), // Bottom-left deep gold
                  Color(0xFFC6BA3C), // Mid-transition metallic gold
                  Color(0xFFEBE385), // Top-right light champagne gold
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
        ),
      ),

      // 2. Main Body Canvas
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Student Financial Record',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Search Input Field Box
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or id',
                  suffixIcon: const Icon(Icons.search, color: Colors.black87),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Custom Header row for the student records table mockup
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Matric ID',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Dynamic Real-Time StreamBuilder List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Queries database for records matching role 'student'
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'student')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Extract documents from snapshot query
                    final allStudents = snapshot.data?.docs ?? [];

                    // Client-side filtering logic matching search bar text
                    final filteredStudents = allStudents.where((doc) {
                      final studentId = doc.id.toUpperCase();
                      final studentData = doc.data() as Map<String, dynamic>?;
                      final studentName =
                          (studentData?['name'] ?? "").toString().toUpperCase();

                      return studentId.contains(_searchQuery) ||
                          studentName.contains(_searchQuery);
                    }).toList();

                    if (filteredStudents.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            'No students found matching search parameter.',
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final doc = filteredStudents[index];
                        final matricId =
                            doc.id; // Document ID is the Student ID
                        final studentData = doc.data() as Map<String, dynamic>?;
                        final name = studentData?['name'] ?? "Unnamed Student";

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TreasuryStuLedger(matricId: matricId),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.grey.shade400),
                                right: BorderSide(color: Colors.grey.shade400),
                                bottom: BorderSide(color: Colors.grey.shade400),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Color(0xFF1B365D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    matricId,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.end,
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
      ),
    );
  }
}
