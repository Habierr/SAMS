import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../Provider/ORController.dart';
import '../OR/StudentOR.dart';
import '../OR/RegisteredCourse.dart';
import '../Attendance/attendanceCheckIn.dart';
import '../Curriculum/my_activity_claims_view.dart';
import '../Finance/stu_finance_dashboard.dart';
import '../../login.dart';

class StudentDashboard extends StatefulWidget {
  final String studentID;
  final String studentName;
  final String year;
  final String semester;

  const StudentDashboard({
    super.key,
    required this.studentID,
    required this.studentName,
    required this.year,
    required this.semester,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Student data (default dari constructor, boleh di-refresh dari Firestore) ──
  late String _studentName;
  String _programme = '';
  late String _year;
  late String _semester;
  String _academicStatus =
      'NOT BLOCKED'; // Dynamic ledger gatekeeping status tracker
  int _totalSubjects = 0;
  int _totalCreditHours = 0;

  bool _isLoading = true;

  // ✅ ORController khusus untuk dashboard ini — supaya boleh akses
  // activeSession (auto isActive dari tarikh+masa)
  final ORController _orController = ORController();

  @override
  void initState() {
    super.initState();
    _studentName = widget.studentName;
    _year = widget.year;
    _semester = widget.semester;
    _loadData();
  }

  // Helper: ambil value pertama yang tak null/kosong dari pelbagai
  // kemungkinan nama field dalam Firestore.
  String _firstNonEmpty(
      Map<String, dynamic> data, List<String> keys, String fallback) {
    for (final k in keys) {
      final v = data[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString();
      }
    }
    return fallback;
  }

  Future<void> _loadData() async {
    try {
      // 1. Load student profile (refresh data terkini, fallback ke widget value)
      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentID)
          .get();

      if (!mounted) return;

      if (studentDoc.exists) {
        final data = studentDoc.data()!;

        // Debug: papar semua field yang ada dalam dokumen user ini
        // (buka Run/Debug Console untuk tengok output ni)
        debugPrint('STUDENT DOC DATA for ${widget.studentID}: $data');

        setState(() {
          _studentName = _firstNonEmpty(
            data,
            ['name', 'studentName', 'Name', 'fullName', 'full_name'],
            widget.studentName,
          );
          _programme = _firstNonEmpty(
            data,
            ['programme', 'program', 'Programme'],
            '',
          );
          _year = _firstNonEmpty(
            data,
            ['year', 'Year', 'studentYear'],
            widget.year,
          );
          _semester = _firstNonEmpty(
            data,
            ['semester', 'Semester', 'sem'],
            widget.semester,
          );
          _academicStatus = data['status'] ??
              'NOT BLOCKED'; // 👈 Dynamically tracks database state values
        });
      } else {
        debugPrint('STUDENT DOC NOT FOUND for studentID: ${widget.studentID}');
      }

      // 2. ✅ Load OR session melalui ORController — isActive auto-calculate
      // dari tarikh+masa (bukan field 'isActive' dalam Firestore)
      await _orController.loadData();

      // 3. Load registered courses untuk student ni
      final regQuery = await FirebaseFirestore.instance
          .collection('registrations')
          .where('studentID', isEqualTo: widget.studentID)
          .where('regStatus', isEqualTo: 'Registered')
          .get();

      if (!mounted) return;

      // Kira unique subjects dan total credit hours
      final Set<String> uniqueSubjects = {};
      int totalCH = 0;

      for (final doc in regQuery.docs) {
        final d = doc.data();
        final subCode = d['subCode'] ?? '';
        final classType = d['classType'] ?? '';

        // Kira sekali sahaja per subject (guna lecture je)
        if (classType == 'Lecture' && !uniqueSubjects.contains(subCode)) {
          uniqueSubjects.add(subCode);
          totalCH += (d['creditHour'] as num?)?.toInt() ?? 0;
        }
      }

      setState(() {
        _totalSubjects = uniqueSubjects.length;
        _totalCreditHours = totalCH;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── Intercept Verification Logic Helper ─────────────────────────────────
  bool _isAccessBlocked() {
    if (_academicStatus.trim().toUpperCase() == 'BLOCKED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please settle your student fees before allowed access'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true; // Stop execution
    }
    return false; // Access granted
  }

  // ── Navigate ke StudentOR ────────────────────────────────────────────────
  void _goToCourseRegistration() {
    if (_isAccessBlocked()) return; // Halts route if blocked

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ORController(),
          child: StudentOR(
            studentID: widget.studentID,
            studentName: _studentName,
            programme: _programme,
          ),
        ),
      ),
    );
  }

  // ── Navigate ke RegisteredCoursePage ("Registered course") ─────────────
  void _goToRegisteredCourse() {
    if (_isAccessBlocked()) return; // Halts route if blocked

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (context) => ORController()
            ..setCurrentUser(studentID: widget.studentID)
            ..loadData(),
          child: const RegisteredCourse(),
        ),
      ),
    ).then((_) {
      // Refresh dashboard stats selepas balik dari RegisteredCourse
      _loadData();
    });
  }

  // ── Navigate ke AttendanceCheckIn ("My Courses") ────────────────────────
  void _goToMyCourses() {
    if (_isAccessBlocked()) return; // Halts route if blocked

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceCheckIn(
          studentName: _studentName,
          studentId: widget.studentID,
        ),
      ),
    );
  }

  // ── Navigate ke MyActivityClaimsView ("Co-curriculum") ──────────────────
  void _goToCoCurriculum() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyActivityClaimsView(),
      ),
    );
  }

  // ── Initials dari nama ───────────────────────────────────────────────────
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF2F4F7),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF11A06E), Color(0xFF48C598)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF11A06E), size: 40),
              ),
              accountName: const Text('Student Portal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              accountEmail: const Text('@student.umpsa.edu.my'),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF11A06E)),
              title: const Text('Main Home Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Color(0xFF11A06E)),
              title: const Text('My Courses'),
              onTap: () {
                Navigator.pop(context);
                _goToMyCourses(); // 👈 Checked
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.app_registration, color: Color(0xFF11A06E)),
              title: const Text('Course Registration'),
              onTap: () {
                Navigator.pop(context);
                _goToCourseRegistration(); // 👈 Checked
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups, color: Color(0xFF11A06E)),
              title: const Text('Co-curriculum'),
              onTap: () {
                Navigator.pop(context);
                _goToCoCurriculum();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet,
                  color: Color(0xFF11A06E)),
              title: const Text('Tuition Fee Finance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StuFinanceDashboard(
                          loggedInStudentMatricId: widget.studentID)),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1AAFA0)),
            )
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF1AAFA0),
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 12),
                        _buildStatsRow(),
                        const SizedBox(height: 12),
                        _buildORSessionCard(),
                        const SizedBox(height: 12),
                        _buildMenuCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1AAFA0), Color(0xFF0D8C7F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              const Expanded(
                child: Text(
                  'STUDENT ACADEMIC\nMANAGEMENT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    height: 1.3,
                  ),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Image.asset(
                  'assets/logo_umpsa.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Profile Card ─────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFD6F5F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(_studentName),
                style: const TextStyle(
                  color: Color(0xFF0D8C7F),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _studentName.isEmpty ? '(No name)' : _studentName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.studentID} · Year $_year',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _semester,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (_academicStatus.trim().toUpperCase() == 'BLOCKED')
                      const Text(
                        'BLOCKED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Stats Row ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            value: '$_totalSubjects',
            label: 'Subjects',
            color: const Color(0xFF5B8CF5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            value: '$_totalCreditHours',
            label: 'Credit hours',
            color: const Color(0xFF1AAFA0),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- OR Session Card ──────────────────────────────────────────────────────
  Widget _buildORSessionCard() {
    return AnimatedBuilder(
      animation: _orController,
      builder: (context, _) {
        final session = _orController.activeSession;
        final isActive = session?.isActive ?? false;
        final period = session?.displayDateRange ?? '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1AAFA0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'OR session',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFD6F5F1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive
                          ? 'Active'
                          : (session?.statusLabel ?? 'Inactive'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? const Color(0xFF0D8C7F)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (period.isNotEmpty)
                Text(
                  'Period: $period',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                Text(
                  'No OR period set yet.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _goToRegisteredCourse, // 👈 Checked
                    borderRadius: BorderRadius.circular(8),
                    splashColor: const Color(0xFF1AAFA0).withOpacity(0.15),
                    highlightColor: const Color(0xFF1AAFA0).withOpacity(0.08),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCCCCCC)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Registered course',
                          style: TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Menu Card ────────────────────────────────────────────────────────────
  Widget _buildMenuCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1AAFA0),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMenuButton(
                  label: 'Course Registration',
                  onTap: _goToCourseRegistration, // 👈 Checked
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMenuButton(
                  label: 'My Courses',
                  onTap: _goToMyCourses, // 👈 Checked
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMenuButton(
                  label: 'Co-curriculum',
                  onTap: _goToCoCurriculum,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMenuButton(
                  label: 'Finance',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StuFinanceDashboard(
                              loggedInStudentMatricId: widget.studentID)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: const Color(0xFF1AAFA0).withOpacity(0.25),
        highlightColor: const Color(0xFF1AAFA0).withOpacity(0.12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
