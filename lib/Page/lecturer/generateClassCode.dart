import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams/Page/lecturer/lecturer_dashboard.dart';

class GenerateClassCode extends StatefulWidget {
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

  const GenerateClassCode({
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
  State<GenerateClassCode> createState() => _GenerateClassCodeState();
}

class _GenerateClassCodeState extends State<GenerateClassCode> {
  DateTime? selectedDate;
  String generatedCode = '';
  bool isLoading = false;

  String generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return List.generate(
      6,
          (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> pickDate() async {
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

  Future<void> copyGeneratedCode() async {
    if (generatedCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No class code to copy yet')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: generatedCode));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class code copied successfully!')),
    );
  }

  Future<void> saveClassCode() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date')),
      );
      return;
    }

    final dateText =
        '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

    final startText = widget.startTime;
    final endText = widget.endTime;

    setState(() {
      isLoading = true;
      generatedCode = generateRandomCode();
    });

    try {
      await FirebaseFirestore.instance
          .collection('classCode')
          .doc(generatedCode)
          .set({
        'lecturerID': widget.lecturerId,
        'lecturerName': widget.lecturerName,

        'regID': widget.regID,

        'subCode': widget.subCode,
        'subName': widget.subName,

        'classType': widget.classType,
        'semester': widget.semester,

        'section': widget.sectionNo,
        'classSession': widget.classType,

        'sessionDate': dateText,
        'startTime': startText,
        'endTime': endText,
        'sessionTime': '$startText - $endText',

        'registrationDay': widget.day,
        'registrationStartTime': widget.startTime,
        'registrationEndTime': widget.endTime,

        'generatedCode': generatedCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving class code: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> showSuccessDialog() async {
    await showDialog(
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
                  'Class code generate\nsuccessfully',
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

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? ''
        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

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
              'Generate Class Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              widget.subCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '${widget.subName} | ${widget.classType} (${widget.sectionNo})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '${widget.day}, ${widget.startTime} - ${widget.endTime} | ${widget.semester}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                const SizedBox(
                  width: 75,
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
                    child: _inputBox(
                      text: dateText,
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
                  width: 75,
                  child: Text(
                    'Section:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111B4D),
                    ),
                  ),
                ),
                Expanded(
                  child: _inputBox(
                    text: widget.sectionNo,
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
                    'Class Time:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111B4D),
                    ),
                  ),
                ),
                Expanded(
                  child: _inputBox(
                    text: '${widget.startTime} - ${widget.endTime}',
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
                    'Session:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111B4D),
                    ),
                  ),
                ),
                Expanded(
                  child: _inputBox(
                    text: widget.classType,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A00D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: isLoading ? null : saveClassCode,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Generate Class Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: copyGeneratedCode,
                  child: Container(
                    width: 180,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      generatedCode.isEmpty ? '' : generatedCode,
                      style: TextStyle(
                        fontSize: generatedCode.isEmpty ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111B4D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    color: Color(0xFF5A00D6),
                  ),
                  onPressed: copyGeneratedCode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBox({
    required String text,
    IconData? icon,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment:
        icon == null ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
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
    );
  }
}
