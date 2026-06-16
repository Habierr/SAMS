import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Page to display curriculum claims based on selected status
class ClaimListByStatusPage extends StatelessWidget {
  final String status;

  const ClaimListByStatusPage({
    super.key,
    required this.status,
  });

  // Return color based on claim status
  Color getStatusColor(String status) {
    if (status == 'APPROVED') return Colors.green.shade400;
    if (status == 'REJECTED') return Colors.red;
    return Colors.yellow.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildBlueAppBar(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title based on selected claim status
            Text(
              status == 'PENDING'
                  ? 'Pending Approval'
                  : status == 'APPROVED'
                  ? 'Approved Claims'
                  : 'Rejected Claims',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Retrieve curriculum claims from Firestore based on status
                stream: FirebaseFirestore.instance
                    .collection('curriculum_claims')
                    .where('status', isEqualTo: status)
                    .snapshots(),

                builder: (context, snapshot) {
                  // Show loading indicator while waiting for data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Display message when no claim data is found
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No $status claims found'));
                  }

                  final claims = snapshot.data!.docs;

                  // Display claim list
                  return ListView.builder(
                    itemCount: claims.length,
                    itemBuilder: (context, index) {
                      final doc = claims[index];
                      final data = doc.data() as Map<String, dynamic>;

                      // Extract claim data from Firestore document
                      final studentId = data['student_id'] ?? '';
                      final activityName = data['activity_name'] ?? '';
                      final claimStatus =
                          data['status']?.toString().toUpperCase() ?? status;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 22),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Display student ID and activity name
                            Expanded(
                              child: Text(
                                '$studentId\n${activityName.toString().toUpperCase()}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),

                            Column(
                              children: [
                                // Display claim status label
                                Container(
                                  width: 90,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(claimStatus),
                                  ),
                                  child: Text(
                                    claimStatus,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Button to view selected claim details
                                SizedBox(
                                  width: 90,
                                  height: 35,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF8B8CF0),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () {
                                      // Navigate to claim details page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PusatAdabClaimDetailsPage(
                                            docId: doc.id,
                                            claimData: data,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'VIEW\nDETAILS',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

// Page to display full details of selected curriculum claim
class PusatAdabClaimDetailsPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> claimData;

  const PusatAdabClaimDetailsPage({
    super.key,
    required this.docId,
    required this.claimData,
  });

  @override
  Widget build(BuildContext context) {
    // Extract claim information from Firestore data
    final studentId = claimData['student_id'] ?? '';
    final activityName = claimData['activity_name'] ?? '';
    final activityDate = claimData['activity_date'] ?? '';
    final duration = claimData['duration_hours'] ?? '';
    final description = claimData['description'] ?? '';
    final fileName = claimData['supporting_file_name'] ?? '';
    final status = claimData['status']?.toString().toUpperCase() ?? 'PENDING';
    final rejectionReason = claimData['rejection_reason'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildBlueAppBar(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
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
              // Details page title
              const Text(
                'Claim Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // Display student matric number
              Text(
                'Matric Number : $studentId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const Divider(height: 30, thickness: 1),

              // Display activity information
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

              // Display claim description
              Text(
                description,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 22),

              // Button to display uploaded supporting document name
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Show supporting document information
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          fileName.toString().isEmpty
                              ? 'No document uploaded'
                              : 'Document: $fileName',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF163DB8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  icon: const Icon(Icons.inventory_2, color: Colors.white),
                  label: const Text(
                    'View Document',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 45),

              // Show approve and reject buttons only for pending claims
              if (status == 'PENDING')
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          // Approve selected claim
                          onPressed: () => approveClaim(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6DDB66),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text(
                            'APPROVED',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 25),

                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          // Open rejection reason dialog
                          onPressed: () => showRejectDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4E55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: const Text(
                            'REJECTED',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // Display message when claim has been approved
              if (status == 'APPROVED')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'This claim has been approved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),

              // Display rejection reason when claim has been rejected
              if (status == 'REJECTED')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    rejectionReason.toString().isEmpty
                        ? 'Reason:\nNo rejection reason provided.'
                        : 'Reason:\n$rejectionReason',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to approve selected claim
  Future<void> approveClaim(BuildContext context) async {
    // Update claim status to APPROVED in Firestore
    await FirebaseFirestore.instance
        .collection('curriculum_claims')
        .doc(docId)
        .update({
      'status': 'APPROVED',

      // Store review timestamp for audit tracking
      'reviewed_at': FieldValue.serverTimestamp(),
    });

    // Display approval success dialog
    showSuccessDialog(
      context,
      Icons.check,
      const Color(0xFF2ECC71),
      'Activity claim approved\nsuccessfully.',
    );
  }

  // Function to display rejection dialog
  void showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 25, 25, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button for rejection dialog
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),

                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.yellow,
                  size: 70,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Please provide a reason\nfor rejection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                // Text field for reviewer to enter rejection reason
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Type here',
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Submit rejection reason
                SizedBox(
                  width: 110,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate rejection reason before updating Firestore
                      if (reasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter rejection reason'),
                          ),
                        );
                        return;
                      }

                      // Update claim status to REJECTED and save reason
                      await FirebaseFirestore.instance
                          .collection('curriculum_claims')
                          .doc(docId)
                          .update({
                        'status': 'REJECTED',
                        'rejection_reason': reasonController.text.trim(),

                        // Store review timestamp for audit tracking
                        'reviewed_at': FieldValue.serverTimestamp(),
                      });

                      // Close rejection dialog
                      Navigator.pop(dialogContext);

                      // Display rejection success dialog
                      showSuccessDialog(
                        context,
                        Icons.close,
                        const Color(0xFFFF1F5B),
                        'Activity claim rejected\nsuccessfully.',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A00E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
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

  // Function to display success dialog after approve or reject action
  void showSuccessDialog(
    BuildContext context,
    IconData icon,
    Color color,
    String message,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 35, 24, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon container
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.45),
                        blurRadius: 18,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 48),
                ),

                const SizedBox(height: 25),

                // Success message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A44),
                  ),
                ),

                const SizedBox(height: 25),

                // Close dialog and return to previous pages
                SizedBox(
                  width: 115,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close success dialog
                      Navigator.pop(dialogContext);

                      // Return to previous page
                      Navigator.pop(context);

                      // Return to status list page
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A00E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
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
}

// Reusable blue gradient app bar for review curriculum claim pages
PreferredSize _buildBlueAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(130),
    child: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,

      // Menu/back button
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
        onPressed: () => Navigator.pop(context),
      ),

      // App bar title
      title: const Text(
        'REVIEW CURRICULUM\nCLAIMS',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
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
            height: 55,
            fit: BoxFit.contain,
          ),
        ),
      ],

      // Blue gradient background
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003EA1),
              Color(0xFF4A69D6),
              Color(0xFF8FA3F0),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
      ),
    ),
  );
}
