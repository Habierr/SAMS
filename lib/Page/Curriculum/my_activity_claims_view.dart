import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_claim_form_view.dart';
import 'claim_details_view.dart';

// Page to display all activity claims submitted by student
class MyActivityClaimsView extends StatelessWidget {
  const MyActivityClaimsView({super.key});

  // Return main color based on claim status
  Color getStatusColor(String status) {
    if (status == 'APPROVED') return const Color(0xFF5FCB6A);
    if (status == 'REJECTED') return const Color(0xFFFF4B4B);
    return const Color(0xFFFFEB63);
  }

  // Return icon based on claim status
  IconData getStatusIcon(String status) {
    if (status == 'APPROVED') return Icons.check_circle_outline;
    if (status == 'REJECTED') return Icons.cancel_outlined;
    return Icons.hourglass_empty;
  }

  // Return soft background color based on claim status
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

      // Main body container
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
              // Button to submit a new activity claim
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

                    // Navigate to new activity claim form
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ActivityClaimFormView(),
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
                  // Retrieve activity claims from Firestore, newest first
                  stream: FirebaseFirestore.instance
                      .collection('curriculum_claims')
                      .orderBy('submitted_at', descending: true)
                      .snapshots(),

                  builder: (context, snapshot) {
                    // Display loading indicator while waiting for data
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Display message if there is no claim record
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No activity claim found',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    final claims = snapshot.data!.docs;

                    // Display claim records in list view
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: claims.length,
                      itemBuilder: (context, index) {
                        final doc = claims[index];
                        final data = doc.data() as Map<String, dynamic>;

                        // Extract claim data from Firestore document
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

  // Reusable app bar for my activity claims page
  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(145),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,

        // Menu button to return to previous page
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

        // App bar title
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

  // Reusable card widget to display one activity claim record
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
          // Add shadow effect to make the card stand out
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          // Status icon circle
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

          // Claim basic information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student ID
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 4),

                // Activity name
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 10),

                // Activity date
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

                // Activity duration
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

          // Status and action buttons section
          Column(
            children: [
              // Claim status badge
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

              // Button to view claim details
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

                  // Navigate to activity claim details page
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClaimDetailsView(
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

              // Show edit button only for pending claims
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

                    // Navigate to edit claim page
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
