import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pending_claims_list.dart';

class ReviewCurriculumClaims extends StatelessWidget {
  const ReviewCurriculumClaims({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('curriculum_claims')
                .snapshots(),
            builder: (context, snapshot) {
              int pending = 0;
              int approved = 0;
              int rejected = 0;

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status =
                      data['status']?.toString().toUpperCase() ?? 'PENDING';

                  if (status == 'PENDING') pending++;
                  if (status == 'APPROVED') approved++;
                  if (status == 'REJECTED') rejected++;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Approval details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  StatusCard(
                    number: pending.toString(),
                    label: 'PENDING',
                    color: const Color(0xFFFFFF66),
                    icon: Icons.hourglass_empty,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ClaimListByStatusPage(status: 'PENDING'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  StatusCard(
                    number: approved.toString(),
                    label: 'APPROVED',
                    color: const Color(0xFF6DDB66),
                    icon: Icons.check_circle_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ClaimListByStatusPage(status: 'APPROVED'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  StatusCard(
                    number: rejected.toString(),
                    label: 'REJECTED',
                    color: const Color(0xFFFF4E55),
                    icon: Icons.cancel_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ClaimListByStatusPage(status: 'REJECTED'),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
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
        title: const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'REVIEW CURRICULUM\nCLAIMS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
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
}

class StatusCard extends StatelessWidget {
  final String number;
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const StatusCard({
    super.key,
    required this.number,
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 130,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 42,
                      color: Color(0xFF0047CC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF0047CC),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}