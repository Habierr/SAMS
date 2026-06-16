import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

// Page for student to edit and resubmit activity claim
class EditActivityClaimPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> claimData;

  const EditActivityClaimPage({
    super.key,
    required this.docId,
    required this.claimData,
  });

  @override
  State<EditActivityClaimPage> createState() => _EditActivityClaimPageState();
}

class _EditActivityClaimPageState extends State<EditActivityClaimPage> {
  // Controllers for claim form fields
  late TextEditingController studentIdController;
  late TextEditingController activityNameController;
  late TextEditingController activityDateController;
  late TextEditingController durationController;
  late TextEditingController descriptionController;

  // Variables to store selected supporting document details
  String? selectedFileName;
  String? selectedFilePath;

  // Variable to control resubmission loading state
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Load existing student ID from Firestore data
    studentIdController = TextEditingController(
      text: widget.claimData['student_id'] ?? '',
    );

    // Load existing activity name from Firestore data
    activityNameController = TextEditingController(
      text: widget.claimData['activity_name'] ?? '',
    );

    // Load existing activity date from Firestore data
    activityDateController = TextEditingController(
      text: widget.claimData['activity_date'] ?? '',
    );

    // Load existing duration from Firestore data
    durationController = TextEditingController(
      text: widget.claimData['duration_hours'] ?? '',
    );

    // Load existing description from Firestore data
    descriptionController = TextEditingController(
      text: widget.claimData['description'] ?? '',
    );

    // Load existing supporting document information
    selectedFileName = widget.claimData['supporting_file_name'];
    selectedFilePath = widget.claimData['supporting_file_path'];
  }

  // Allow user to select a new supporting document
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    // Save selected file name and path
    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
        selectedFilePath = result.files.single.path;
      });
    }
  }

  // Update existing claim and resubmit for review
  Future<void> resubmitClaim() async {
    // Validate all required fields before resubmission
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

    // Enable loading state during resubmission
    setState(() {
      isSubmitting = true;
    });

    // Update claim information in Firestore
    await FirebaseFirestore.instance
        .collection('curriculum_claims')
        .doc(widget.docId)
        .update({
      'student_id': studentIdController.text.trim(),
      'activity_name': activityNameController.text.trim(),
      'activity_date': activityDateController.text.trim(),
      'duration_hours': durationController.text.trim(),
      'description': descriptionController.text.trim(),

      // Update supporting document information
      'supporting_file_name': selectedFileName,
      'supporting_file_path': selectedFilePath,

      // Reset claim status to pending after edit
      'status': 'PENDING',

      // Store update timestamp
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Disable loading state after successful update
    setState(() {
      isSubmitting = false;
    });

    // Display success dialog after resubmission
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
                  'Activity claim updated\nsuccessfully. Status:\nPending Review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF24324A),
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
  void dispose() {
    // Dispose controllers to avoid memory leaks
    studentIdController.dispose();
    activityNameController.dispose();
    activityDateController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // App bar for edit activity claim page
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
            'EDIT ACTIVITY\nCLAIM',
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

          // Green gradient background
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

      // Main edit claim form body
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
                // Student ID field
                _buildLabel('Student ID'),
                _buildTextField(controller: studentIdController),

                // Activity name field
                _buildLabel('Activity Name'),
                _buildTextField(controller: activityNameController),

                // Activity date field
                _buildLabel('Activity Date'),
                _buildTextField(controller: activityDateController),

                // Duration field
                _buildLabel('Duration (Hours)'),
                _buildTextField(controller: durationController),

                // Description field
                _buildLabel('Description'),
                _buildTextField(
                  controller: descriptionController,
                  height: 90,
                ),

                const SizedBox(height: 15),

                // Supporting document title
                const Text(
                  'Attach Supporting Document',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),

                const SizedBox(height: 12),

                // Upload or replace supporting document
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
                    icon: const Icon(Icons.upload_file, color: Colors.white),
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

                // Display selected supporting document name
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

                // Resubmit button container with gradient background
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

                  // Button to resubmit edited claim
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : resubmitClaim,
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
                      isSubmitting ? 'RESUBMITTING...' : 'RESUBMIT',
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

  // Reusable text field widget for edit form
  Widget _buildTextField({
    required TextEditingController controller,
    double height = 50,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: height,
        child: TextField(
          controller: controller,
          maxLines: height > 60 ? 4 : 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
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
}

// Page to display activity claim details
class ClaimDetailsView extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> claimData;

  const ClaimDetailsView({
    super.key,
    required this.docId,
    required this.claimData,
  });

  @override
  State<ClaimDetailsView> createState() => _ClaimDetailsViewState();
}

class _ClaimDetailsViewState extends State<ClaimDetailsView> {
  // Variables to store newly uploaded file information
  String? newFileName;
  String? newFilePath;

  // Variable to control upload loading state
  bool isUploading = false;

  // Allow student to upload supporting document again after rejection
  Future<void> uploadFileAgain() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      // Store new uploaded file information
      setState(() {
        newFileName = result.files.single.name;
        newFilePath = result.files.single.path;
        isUploading = true;
      });

      // Update Firestore with new document and reset status to pending
      await FirebaseFirestore.instance
          .collection('curriculum_claims')
          .doc(widget.docId)
          .update({
        'supporting_file_name': newFileName,
        'supporting_file_path': newFilePath,

        // Reset rejected claim status to pending review
        'status': 'PENDING',

        // Clear old rejection reason after resubmission
        'rejection_reason': '',

        // Store resubmission timestamp
        'resubmitted_at': FieldValue.serverTimestamp(),
      });

      // Stop upload loading state
      setState(() {
        isUploading = false;
      });

      // Inform user that document has been uploaded again
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded again. Status: Pending Review.'),
        ),
      );

      // Return to previous page after upload
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract claim data from Firestore document
    final studentId = widget.claimData['student_id'] ?? '';
    final activityName = widget.claimData['activity_name'] ?? '';
    final activityDate = widget.claimData['activity_date'] ?? '';
    final duration = widget.claimData['duration_hours'] ?? '';
    final description = widget.claimData['description'] ?? '';
    final fileName = widget.claimData['supporting_file_name'] ?? '';
    final rejectionReason = widget.claimData['rejection_reason'] ??
        'Document not valid. Please try to resubmit with correct format';

    final status =
        widget.claimData['status']?.toString().toUpperCase() ?? 'PENDING';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // App bar for activity claim details page
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
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
            'MY ACTIVITY\nCLAIMS',
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
                width: 50,
              ),
            ),
          ],

          // Green gradient background
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

      // Main claim details body
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title
              const Text(
                'Activity Claim Details',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              // Display student matric number
              Text(
                'Matric Number : $studentId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const Divider(height: 30, thickness: 1),

              // Display activity name
              Text(
                'Activity Name: $activityName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 14),

              // Display activity date
              Text(
                'Date : $activityDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 14),

              // Display activity duration
              Text(
                'Hours: $duration hours',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const Divider(height: 32, thickness: 1),

              const Text(
                'Description :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              // Display activity description
              Text(
                description,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 22),

              // Button to view uploaded document name
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Display uploaded document name in dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Uploaded Document'),
                          content: Text(
                            fileName.toString().isEmpty
                                ? 'No document uploaded'
                                : fileName.toString(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF163DB8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  icon: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'View Document',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Show upload file again button only when claim is rejected
              if (status == 'REJECTED')
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: isUploading ? null : uploadFileAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4F55),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    icon: const Icon(
                      Icons.priority_high,
                      color: Colors.white,
                    ),
                    label: Text(
                      isUploading ? 'Uploading...' : 'Upload File Again',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 26),

              // Display claim status box
              _buildStatusBox(status, rejectionReason.toString()),
            ],
          ),
        ),
      ),
    );
  }

  // Build status message box based on claim status
  Widget _buildStatusBox(String status, String rejectionReason) {
    Color color;

    // Select status color
    if (status == 'APPROVED') {
      color = Colors.green;
    } else if (status == 'REJECTED') {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: color,
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Display rejection reason if claim is rejected
          if (status == 'REJECTED')
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'Reason:\n$rejectionReason',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),
            ),

          // Display pending message
          if (status == 'PENDING')
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Your claim is waiting for review.',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 15,
                ),
              ),
            ),

          // Display approved message
          if (status == 'APPROVED')
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Your claim has been approved.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
