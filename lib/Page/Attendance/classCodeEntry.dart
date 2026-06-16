import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sams/Page/Attendance/attendanceCheckIn.dart';
import 'package:sams/Page/student/student_dashboard.dart';

class ClassCodeEntry extends StatefulWidget {
  // Student and selected subject information
  final String studentName;
  final String studentId;
  final String subCode;
  final String subName;

  const ClassCodeEntry({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.subCode,
    required this.subName,
  });

  @override
  State<ClassCodeEntry> createState() => _ClassCodeEntryState();
}

class _ClassCodeEntryState extends State<ClassCodeEntry> {
  final TextEditingController _classCodeController = TextEditingController();
  bool isLoading = false;

  // UMPSA campus location and allowed attendance radius
  final double umpsaLat = 3.5437;
  final double umpsaLng = 103.4273;
  final double allowedRadiusMeter = 1000;

  // Check whether location service and permission are allowed
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await showErrorDialog('Please enable location first.');
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await showErrorDialog(
        'Location permission is required to record attendance.',
      );
      return false;
    }

    return true;
  }

  // Generate unique attendance ID using Firestore transaction
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

  // Validate class code, check location, and save attendance record
  Future<void> submitAttendance() async {
    final enteredCode = _classCodeController.text.trim().toUpperCase();

    if (enteredCode.isEmpty) {
      await showInvalidCodeDialog();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final hasPermission = await checkLocationPermission();

      if (!hasPermission) {
        setState(() => isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        umpsaLat,
        umpsaLng,
      );

      if (distance > allowedRadiusMeter) {
        setState(() => isLoading = false);
        await showOutsideCampusDialog();
        return;
      }

      final classCodeDoc = await FirebaseFirestore.instance
          .collection('classCode')
          .doc(enteredCode)
          .get();

      if (!classCodeDoc.exists) {
        setState(() => isLoading = false);
        await showInvalidCodeDialog();
        return;
      }

      final classData = classCodeDoc.data() as Map<String, dynamic>;

      if (classData['generatedCode'] != enteredCode ||
          classData['subCode'] != widget.subCode) {
        setState(() => isLoading = false);
        await showInvalidCodeDialog();
        return;
      }

      final registrationSnapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .where('studentID', isEqualTo: widget.studentId)
          .where('subCode', isEqualTo: widget.subCode)
          .where('regStatus', isEqualTo: 'Registered')
          .limit(1)
          .get();

      if (registrationSnapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        await showErrorDialog('Student registration record not found.');
        return;
      }

      final duplicateCheck = await FirebaseFirestore.instance
          .collection('attendance')
          .where('studentID', isEqualTo: widget.studentId)
          .where('subCode', isEqualTo: widget.subCode)
          .where('classCode', isEqualTo: enteredCode)
          .limit(1)
          .get();

      if (duplicateCheck.docs.isNotEmpty) {
        setState(() => isLoading = false);
        await showErrorDialog(
            'Attendance already recorded for this class code.');
        return;
      }

      final attendanceId = await generateAttendanceId();

      // Save attendance record into Firestore
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(attendanceId)
          .set({
        'attendanceID': attendanceId,
        'studentID': widget.studentId,
        'studentName': widget.studentName,
        'subCode': widget.subCode,
        'subName': widget.subName,
        'regID': classData['regID'] ?? '',
        'section': classData['section'] ?? '',
        'classSession': classData['classSession'] ?? '',
        'classCode': enteredCode,
        'sessionDate': classData['sessionDate'] ?? '',
        'sessionTime': classData['sessionTime'] ?? '',
        'location': '${position.latitude}, ${position.longitude}',
        'attendanceStatus': 'Present',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => isLoading = false);

      await showSuccessDialog(
        subName: widget.subName,
        date: classData['sessionDate'] ?? '',
        section: classData['section'] ?? '',
        time: classData['sessionTime'] ?? '',
        session: classData['classSession'] ?? '',
      );
    } catch (e) {
      setState(() => isLoading = false);
      await showErrorDialog('Error: $e');
    }
  }

  // Display success message after attendance is recorded
  Future<void> showSuccessDialog({
    required String subName,
    required String date,
    required String section,
    required String time,
    required String session,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            width: 260,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _successIcon(),
                const SizedBox(height: 18),
                const Text(
                  'Attendance Record\nSuccessfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF111B4D),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _popupInfo('Date:', date),
                _popupInfo('Section:', section),
                _popupInfo('Class Time:', time),
                _popupInfo('Session:', session),
                const SizedBox(height: 20),
                _okayButton(() {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // Display invalid class code message
  Future<void> showInvalidCodeDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            width: 250,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _errorIcon(),
                const SizedBox(height: 24),
                const Text(
                  'Invalid class code.\nPlease try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF111B4D),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 26),
                _okayButton(() => Navigator.pop(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Display message when student is outside campus area
  Future<void> showOutsideCampusDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          child: Container(
            width: 250,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _errorIcon(),
                const SizedBox(height: 24),
                const Text(
                  'Attendance cannot\nbe recorded. You\nmust be inside\ncampus area.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF111B4D),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 26),
                _okayButton(() => Navigator.pop(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  // General error dialog
  Future<void> showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notice'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  // Success icon used in popup
  Widget _successIcon() {
    return Container(
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
      child: const Icon(Icons.check, color: Colors.white, size: 46),
    );
  }

  // Error icon used in popup
  Widget _errorIcon() {
    return Container(
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
      child: const Icon(Icons.close, color: Colors.white, size: 46),
    );
  }

  // Reusable popup information row
  Widget _popupInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable okay button for dialog
  Widget _okayButton(VoidCallback onPressed) {
    return SizedBox(
      width: 170,
      height: 38,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5A00D6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          'Okay',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // Student navigation drawer
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
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDashboard(
                      studentName: widget.studentName,
                      studentID: widget.studentId,
                      year: 'Year 3',
                      semester: 'Sem 2',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('My Courses'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceCheckIn(
                      studentName: widget.studentName,
                      studentId: widget.studentId,
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

      // SAMS application header
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
                  Color(0xFF11A06E),
                  Color(0xFF48C598),
                  Color(0xFF88E5BE),
                ],
              ),
            ),
          ),
        ),
      ),

      // Class code entry form
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
            const Text(
              'Class Code Entry',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              widget.subName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
            const SizedBox(height: 35),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter Class Code:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111B4D),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _classCodeController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 170,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A00D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: isLoading ? null : submitAttendance,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit',
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
