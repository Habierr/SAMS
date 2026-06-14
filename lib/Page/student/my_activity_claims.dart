import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sams/student/curriculum_activity_claims.dart';

class MyActivityClaims extends StatelessWidget {
  const MyActivityClaims({super.key});

  Color getStatusColor(String status) {
    if (status == 'APPROVED') return const Color(0xFF5FCB6A);
    if (status == 'REJECTED') return const Color(0xFFFF4B4B);
    return const Color(0xFFFFEB63);
  }

  IconData getStatusIcon(String status) {
    if (status == 'APPROVED') return Icons.check_circle_outline;
    if (status == 'REJECTED') return Icons.cancel_outlined;
    return Icons.hourglass_empty;
  }

  Color getStatusSoftColor(String status) {
    if (status == 'APPROVED') return const Color(0xFFE8FBEA);
    if (status == 'REJECTED') return const Color(0xFFFFE8E8);
    return const Color(0xFFFFF8D8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF11A06E),
                        Color(0xFF48C598),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CurriculumActivityClaims(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'NEW ACTIVITY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('curriculum_claims')
                      .orderBy('submitted_at', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No activity claim found',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    final claims = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: claims.length,
                      itemBuilder: (context, index) {
                        final doc = claims[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final studentId = data['student_id'] ?? '';
                        final activityName = data['activity_name'] ?? '';
                        final activityDate = data['activity_date'] ?? '-';
                        final duration = data['duration_hours'] ?? '-';
                        final status =
                            data['status']?.toString().toUpperCase() ??
                                'PENDING';

                        return _buildClaimCard(
                          context: context,
                          docId: doc.id,
                          data: data,
                          code: studentId.toString(),
                          title: activityName.toString().toUpperCase(),
                          activityDate: activityDate.toString(),
                          duration: duration.toString(),
                          status: status,
                          statusColor: getStatusColor(status),
                          statusSoftColor: getStatusSoftColor(status),
                          statusIcon: getStatusIcon(status),
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

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(145),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          'MY ACTIVITY\nCLAIMS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            height: 1.2,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/logo_umpsa.png',
              width: 50,
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0E9F6E),
                Color(0xFF36C492),
                Color(0xFF7FE2B9),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClaimCard({
    required BuildContext context,
    required String docId,
    required Map<String, dynamic> data,
    required String code,
    required String title,
    required String activityDate,
    required String duration,
    required String status,
    required Color statusColor,
    required Color statusSoftColor,
    required IconData statusIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: statusSoftColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: status == 'PENDING'
                  ? Colors.orange
                  : status == 'APPROVED'
                  ? Colors.green
                  : Colors.red,
              size: 34,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF11A06E),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        activityDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 15,
                      color: Color(0xFF11A06E),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$duration hours',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            children: [
              Container(
                width: 94,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: 94,
                height: 38,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B8CF0),
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityClaimDetailsPage(
                          docId: docId,
                          claimData: data,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'VIEW DETAILS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              if (status == 'PENDING') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: 94,
                  height: 38,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E9F6E),
                      elevation: 3,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditActivityClaimPage(
                            docId: docId,
                            claimData: data,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 15,
                    ),
                    label: const Text(
                      'EDIT',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

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
  late TextEditingController studentIdController;
  late TextEditingController activityNameController;
  late TextEditingController activityDateController;
  late TextEditingController durationController;
  late TextEditingController descriptionController;

  String? selectedFileName;
  String? selectedFilePath;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    studentIdController = TextEditingController(
      text: widget.claimData['student_id'] ?? '',
    );

    activityNameController = TextEditingController(
      text: widget.claimData['activity_name'] ?? '',
    );

    activityDateController = TextEditingController(
      text: widget.claimData['activity_date'] ?? '',
    );

    durationController = TextEditingController(
      text: widget.claimData['duration_hours'] ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.claimData['description'] ?? '',
    );

    selectedFileName = widget.claimData['supporting_file_name'];
    selectedFilePath = widget.claimData['supporting_file_path'];
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

  Future<void> resubmitClaim() async {
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

    await FirebaseFirestore.instance
        .collection('curriculum_claims')
        .doc(widget.docId)
        .update({
      'student_id': studentIdController.text.trim(),
      'activity_name': activityNameController.text.trim(),
      'activity_date': activityDateController.text.trim(),
      'duration_hours': durationController.text.trim(),
      'description': descriptionController.text.trim(),
      'supporting_file_name': selectedFileName,
      'supporting_file_path': selectedFilePath,
      'status': 'PENDING',
      'updated_at': FieldValue.serverTimestamp(),
    });

    setState(() {
      isSubmitting = false;
    });

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
                  'Activity claim updated\nsuccessfully. Status:\nPending Review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF24324A),
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
                _buildTextField(controller: activityDateController),

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

class ActivityClaimDetailsPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> claimData;

  const ActivityClaimDetailsPage({
    super.key,
    required this.docId,
    required this.claimData,
  });

  @override
  State<ActivityClaimDetailsPage> createState() =>
      _ActivityClaimDetailsPageState();
}

class _ActivityClaimDetailsPageState extends State<ActivityClaimDetailsPage> {
  String? newFileName;
  String? newFilePath;
  bool isUploading = false;

  Future<void> uploadFileAgain() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        newFileName = result.files.single.name;
        newFilePath = result.files.single.path;
        isUploading = true;
      });

      await FirebaseFirestore.instance
          .collection('curriculum_claims')
          .doc(widget.docId)
          .update({
        'supporting_file_name': newFileName,
        'supporting_file_path': newFilePath,
        'status': 'PENDING',
        'rejection_reason': '',
        'resubmitted_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded again. Status: Pending Review.'),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                'assets/logo_umpsa.png',
                width: 50,
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
              const Text(
                'Activity Claim Details',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Matric Number : $studentId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const Divider(height: 30, thickness: 1),

              Text(
                'Activity Name: $activityName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Date : $activityDate',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 14),

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

              Text(
                description,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () {
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

              _buildStatusBox(status, rejectionReason.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBox(String status, String rejectionReason) {
    Color color;

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