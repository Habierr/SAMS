import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimListByStatusPage extends StatelessWidget {
  final String status;

  const ClaimListByStatusPage({
    super.key,
    required this.status,
  });

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
                stream: FirebaseFirestore.instance
                    .collection('curriculum_claims')
                    .where('status', isEqualTo: status)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No $status claims found'));
                  }

                  final claims = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: claims.length,
                    itemBuilder: (context, index) {
                      final doc = claims[index];
                      final data = doc.data() as Map<String, dynamic>;

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
                            Expanded(
                              child: Text(
                                '$studentId\n${activityName.toString().toUpperCase()}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Column(
                              children: [
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
                                SizedBox(
                                  width: 90,
                                  height: 35,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B8CF0),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () {
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
              const Text(
                'Claim Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Text(
                'Matric Number : $studentId',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Divider(height: 30, thickness: 1),
              Text(
                'Activity Name: $activityName',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 14),
              Text(
                'Date : $activityDate',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 14),
              Text(
                'Hours: $duration hours',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Divider(height: 32, thickness: 1),
              const Text(
                'Description :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                description,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () {
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
              if (status == 'PENDING')
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
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

  Future<void> approveClaim(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('curriculum_claims')
        .doc(docId)
        .update({
      'status': 'APPROVED',
      'reviewed_at': FieldValue.serverTimestamp(),
    });

    showSuccessDialog(
      context,
      Icons.check,
      const Color(0xFF2ECC71),
      'Activity claim approved\nsuccessfully.',
    );
  }

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
                      child: const Icon(Icons.close, color: Colors.white, size: 30),
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
                SizedBox(
                  width: 110,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (reasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter rejection reason'),
                          ),
                        );
                        return;
                      }

                      await FirebaseFirestore.instance
                          .collection('curriculum_claims')
                          .doc(docId)
                          .update({
                        'status': 'REJECTED',
                        'rejection_reason': reasonController.text.trim(),
                        'reviewed_at': FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(dialogContext);

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
                SizedBox(
                  width: 115,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
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

PreferredSize _buildBlueAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(130),
    child: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
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