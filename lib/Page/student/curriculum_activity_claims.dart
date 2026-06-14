import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurriculumActivityClaims extends StatefulWidget {
  const CurriculumActivityClaims({super.key});

  @override
  State<CurriculumActivityClaims> createState() =>
      _CurriculumActivityClaimsState();
}

class _CurriculumActivityClaimsState extends State<CurriculumActivityClaims> {
  final studentIdController = TextEditingController();
  final activityNameController = TextEditingController();
  final activityDateController = TextEditingController();
  final durationController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedFileName;
  String? selectedFilePath;
  bool isSubmitting = false;

  String makeDocId(String activityName) {
    return activityName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
        selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> pickActivityDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        activityDateController.text =
        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
    }
  }

  Future<void> submitClaim() async {
    if (studentIdController.text.isEmpty ||
        activityNameController.text.isEmpty ||
        activityDateController.text.isEmpty ||
        durationController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields and upload file'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final studentId = studentIdController.text.trim();
      final activityName = activityNameController.text.trim();

      final docId = '${studentId}_${makeDocId(activityName)}';

      await FirebaseFirestore.instance
          .collection('curriculum_claims')
          .doc(docId)
          .set({
        'student_id': studentId,
        'activity_name': activityName,
        'activity_date': activityDateController.text.trim(),
        'duration_hours': durationController.text.trim(),
        'description': descriptionController.text.trim(),
        'supporting_file_name': selectedFileName,
        'supporting_file_path': selectedFilePath,
        'status': 'PENDING',
        'submitted_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        isSubmitting = false;
        selectedFileName = null;
        selectedFilePath = null;
      });

      studentIdController.clear();
      activityNameController.clear();
      activityDateController.clear();
      durationController.clear();
      descriptionController.clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'New activity claim added\nsuccessfully. Status:\nPending Review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF24324A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 115,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C1DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Okay',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submit claim: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    studentIdController.dispose();
    activityNameController.dispose();
    activityDateController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    double height = 50,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: height,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: height > 60 ? 4 : 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: suffixIcon == null
                ? null
                : Icon(
              suffixIcon,
              color: const Color(0xFF11A06E),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black38),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF11A06E),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'CURRICULUM ACTIVITY\nCLAIM',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              height: 1.2,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                'assets/logo_umpsa.png',
                width: 55,
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Student ID'),
                _buildTextField(controller: studentIdController),

                _buildLabel('Activity Name'),
                _buildTextField(controller: activityNameController),

                _buildLabel('Activity Date'),
                _buildTextField(
                  controller: activityDateController,
                  readOnly: true,
                  onTap: pickActivityDate,
                  suffixIcon: Icons.calendar_month,
                ),

                _buildLabel('Duration (Hours)'),
                _buildTextField(controller: durationController),

                _buildLabel('Description'),
                _buildTextField(
                  controller: descriptionController,
                  height: 90,
                ),

                const SizedBox(height: 15),

                const Text(
                  'Attach Supporting Document',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8185E8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.upload_file,
                      color: Colors.white,
                    ),
                    label: Text(
                      selectedFileName ?? 'Upload File',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (selectedFileName != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAFBF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF11A06E),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          color: Color(0xFF11A06E),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedFileName!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF11A06E),
                        Color(0xFF48C598),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : submitClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      isSubmitting ? 'SUBMITTING...' : 'SUBMIT CLAIM',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}