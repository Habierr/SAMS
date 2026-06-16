import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Page for student to submit curriculum activity claim
class ActivityClaimFormView extends StatefulWidget {
  const ActivityClaimFormView({super.key});

  @override
  State<ActivityClaimFormView> createState() =>
      _ActivityClaimFormViewState();
}

class _ActivityClaimFormViewState extends State<ActivityClaimFormView> {
  // Controllers for form input fields
  final studentIdController = TextEditingController();
  final activityNameController = TextEditingController();
  final activityDateController = TextEditingController();
  final durationController = TextEditingController();
  final descriptionController = TextEditingController();

  // Variables to store selected supporting file information
  String? selectedFileName;
  String? selectedFilePath;

  // Variable to prevent multiple submissions at the same time
  bool isSubmitting = false;

  // Generate a clean document ID from activity name
  String makeDocId(String activityName) {
    return activityName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  // Allow user to select supporting document from device
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    // Save selected file name and file path
    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
        selectedFilePath = result.files.single.path;
      });
    }
  }

  // Open date picker to select activity date
  Future<void> pickActivityDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    // Display selected date in the text field
    if (pickedDate != null) {
      setState(() {
        activityDateController.text =
            '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
    }
  }

  // Submit claim data to Firestore
  Future<void> submitClaim() async {
    // Validate all required fields before submission
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

    // Set submit button into loading mode
    setState(() {
      isSubmitting = true;
    });

    try {
      final studentId = studentIdController.text.trim();
      final activityName = activityNameController.text.trim();

      // Create unique document ID using student ID and activity name
      final docId = '${studentId}_${makeDocId(activityName)}';

      // Save activity claim data into Firestore
      await FirebaseFirestore.instance
          .collection('curriculum_claims')
          .doc(docId)
          .set({
        'student_id': studentId,
        'activity_name': activityName,
        'activity_date': activityDateController.text.trim(),
        'duration_hours': durationController.text.trim(),
        'description': descriptionController.text.trim(),

        // Save supporting document information
        'supporting_file_name': selectedFileName,
        'supporting_file_path': selectedFilePath,

        // Set default claim status as pending review
        'status': 'PENDING',

        // Store submission date and time
        'submitted_at': FieldValue.serverTimestamp(),
      });

      // Reset submit state and selected file
      setState(() {
        isSubmitting = false;
        selectedFileName = null;
        selectedFilePath = null;
      });

      // Clear all form input fields after successful submission
      studentIdController.clear();
      activityNameController.clear();
      activityDateController.clear();
      durationController.clear();
      descriptionController.clear();

      // Display success dialog after claim is submitted
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
                  // Success icon
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

                  // Success message
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

                  // Close dialog and return to previous page
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
      // Stop loading state if error occurs
      setState(() {
        isSubmitting = false;
      });

      // Display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submit claim: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    studentIdController.dispose();
    activityNameController.dispose();
    activityDateController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Reusable label widget for form fields
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

  // Reusable text field widget
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

          // Menu button to return to previous page
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          // App bar title
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

          // UMPSA logo
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                'assets/logo_umpsa.png',
                width: 55,
              ),
            ),
          ],

          // Green gradient app bar background
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

      // Main form body
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
                // Student ID input
                _buildLabel('Student ID'),
                _buildTextField(controller: studentIdController),

                // Activity name input
                _buildLabel('Activity Name'),
                _buildTextField(controller: activityNameController),

                // Activity date input
                _buildLabel('Activity Date'),
                _buildTextField(
                  controller: activityDateController,
                  readOnly: true,
                  onTap: pickActivityDate,
                  suffixIcon: Icons.calendar_month,
                ),

                // Duration input
                _buildLabel('Duration (Hours)'),
                _buildTextField(controller: durationController),

                // Description input
                _buildLabel('Description'),
                _buildTextField(
                  controller: descriptionController,
                  height: 90,
                ),

                const SizedBox(height: 15),

                // Supporting document section title
                const Text(
                  'Attach Supporting Document',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),

                const SizedBox(height: 12),

                // Upload supporting document button
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

                // Display selected file name after upload
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

                // Submit button container with gradient background
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

                  // Submit button
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
