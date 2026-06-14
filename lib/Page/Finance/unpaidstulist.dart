import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnpaidStuList extends StatefulWidget {
  const UnpaidStuList({super.key});

  @override
  State<UnpaidStuList> createState() => _UnpaidStuListState();
}

class _UnpaidStuListState extends State<UnpaidStuList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Tracks checked checkboxes by storing their unique Matric IDs
  final Set<String> _selectedStudentIds = {};
  List<QueryDocumentSnapshot> _currentFilteredStudents = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toUpperCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper calculation function to check outstanding fee balance context
  Future<double> _calculateStudentSemBalance(String matricId) async {
    final receiptSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(matricId)
        .collection('receipts')
        .get();

    double semReceived = 0.0;
    for (var doc in receiptSnapshot.docs) {
      final rData = doc.data();
      if (rData['semester'] == 'SEM 2 25/26') {
        semReceived +=
            double.tryParse(rData['totalReceived'].toString()) ?? 0.0;
      }
    }
    double balance = 1510.0 - semReceived;
    return balance < 0 ? 0.0 : balance;
  }

  // --- POPUP DIALOG WINDOWS CONFIGURED TO MATCH DESIGN WIREFRAMES ---

  void _showConfirmationDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String actionButtonText,
    required Color actionButtonColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 80, color: iconColor),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: actionButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close confirm modal
                          onConfirm();
                        },
                        child: Text(
                          actionButtonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessModal(IconData icon, Color iconColor, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 80, color: iconColor),
                const SizedBox(height: 24),
                const Text(
                  'Successful',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(
                        () => _selectedStudentIds.clear(),
                      ); // Clean selections after execution
                    },
                    child: const Text(
                      'OKAY',
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

  // Database Execution Action Loops
  Future<void> _executeBulkBlockStatus(bool standardBlockTrigger) async {
    for (String id in _selectedStudentIds) {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'status': standardBlockTrigger ? 'BLOCKED' : 'NOT BLOCKED',
      });
    }
    _showSuccessModal(
      Icons.check_circle,
      Colors.black,
      standardBlockTrigger
          ? 'The people you selected have been blocked'
          : 'The people you selected have been unblocked',
    );
  }

  Future<void> _toggleSingleBlock(String matricId, String currentStatus) async {
    bool isCurrentlyBlocked = currentStatus.trim().toUpperCase() == 'BLOCKED';
    await FirebaseFirestore.instance.collection('users').doc(matricId).update({
      'status': isCurrentlyBlocked ? 'NOT BLOCKED' : 'BLOCKED',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // Treasury Standard AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'STUDENT ACADEMIC\nMANAGEMENT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/logo_umpsa.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF988B0C),
                  Color(0xFFC6BA3C),
                  Color(0xFFEBE385),
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
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'List of Unsettled Student Fees',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Search Bar Layout Element
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // --- TOP BATCH CONTROLS REGION ROWS ---
              Row(
                children: [
                  Checkbox(
                    value: _currentFilteredStudents.isNotEmpty &&
                        _selectedStudentIds.length ==
                            _currentFilteredStudents.length,
                    onChanged: (bool? checkedValue) {
                      setState(() {
                        if (checkedValue == true) {
                          for (var doc in _currentFilteredStudents) {
                            _selectedStudentIds.add(doc.id);
                          }
                        } else {
                          _selectedStudentIds.clear();
                        }
                      });
                    },
                  ),
                  const Icon(Icons.arrow_drop_down),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 24),
                    onPressed: () => setState(() {}),
                  ),
                  const Spacer(),

                  // Conditional Batch Buttons render if items selected > 1
                  if (_selectedStudentIds.length > 1) ...[
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade700),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.black87,
                          size: 22,
                        ),
                      ),
                      onPressed: () {
                        _showConfirmationDialog(
                          icon: Icons.notifications_none,
                          iconColor: Colors.black87,
                          title: 'Are you sure?',
                          message: 'The people you selected will be notified',
                          actionButtonText: 'NOTIFY',
                          actionButtonColor: Colors.blue.shade800,
                          onConfirm: () => _showSuccessModal(
                            Icons.notifications_active_outlined,
                            Colors.black,
                            'Notification have been sent to their email',
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.block,
                          color: Colors.black87,
                          size: 22,
                        ),
                      ),
                      onPressed: () {
                        _showConfirmationDialog(
                          icon: Icons.block,
                          iconColor: Colors.black87,
                          title: 'Are you sure?',
                          message:
                              'The people you selected will be blocked access',
                          actionButtonText: 'BLOCK',
                          actionButtonColor: Colors.red.shade800,
                          onConfirm: () => _executeBulkBlockStatus(true),
                        );
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Table Content Matrix Headers Row Labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: const [
                    SizedBox(width: 32), // Checkbox width padding spacer
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Sponsor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Days\nUnsettled',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Action',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1.5, color: Colors.black87),

              // Realtime Stream Database Render Engine
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'student')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final rawDocs = snapshot.data!.docs;

                    // Execute future calculation filtering and update view array safely
                    return FutureBuilder<List<QueryDocumentSnapshot>>(
                      future: Future.wait(
                        rawDocs.map((doc) async {
                          double bal = await _calculateStudentSemBalance(
                            doc.id,
                          );
                          return MapEntry(doc, bal);
                        }),
                      ).then((entries) {
                        return entries
                            .where(
                              (entry) => entry.value > 0,
                            ) // Only displays students with outstanding fee balance > 0
                            .map((entry) => entry.key)
                            .toList();
                      }),
                      builder: (context, futureSnapshot) {
                        if (!futureSnapshot.hasData)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        final studentDocs = futureSnapshot.data!;

                        // Local runtime search bar filtering assignment matches
                        _currentFilteredStudents = studentDocs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name =
                              (data['name'] ?? '').toString().toUpperCase();
                          return name.contains(_searchQuery);
                        }).toList();

                        if (_currentFilteredStudents.isEmpty) {
                          return const Center(
                            child: Text(
                              'No unsettled student entries available.',
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: _currentFilteredStudents.length,
                          itemBuilder: (context, index) {
                            final doc = _currentFilteredStudents[index];
                            final matricId = doc.id;
                            final data = doc.data() as Map<String, dynamic>;

                            final name = data['name'] ?? 'N/A';
                            final sponsor = data['sponsor'] ?? 'NONE';
                            final currentStatus =
                                (data['status'] ?? 'NOT BLOCKED').toString();
                            bool isBlocked =
                                currentStatus.trim().toUpperCase() == 'BLOCKED';

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _selectedStudentIds.contains(
                                      matricId,
                                    ),
                                    onChanged: (bool? checkedValue) {
                                      setState(() {
                                        if (checkedValue == true) {
                                          _selectedStudentIds.add(matricId);
                                        } else {
                                          _selectedStudentIds.remove(matricId);
                                        }
                                      });
                                    },
                                  ),

                                  // Name column layout region text
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        color: Color(0xFF1B365D),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // Sponsor display
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      sponsor,
                                      style: TextStyle(
                                        color: sponsor == 'NONE'
                                            ? Colors.orange.shade800
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // Hardcoded placeholder days tracker matched to mock template specs
                                  Expanded(
                                    flex: 2,
                                    child: const Text(
                                      '35',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  // Dual functional interaction buttons stack region configuration
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 65,
                                          height: 24,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF1B365D,
                                              ),
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () => _showSuccessModal(
                                              Icons
                                                  .notifications_active_outlined,
                                              Colors.black,
                                              'Notification has been sent to $name\'s email',
                                            ),
                                            child: const Text(
                                              'NOTIFY',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          width: 65,
                                          height: 24,
                                          child: ElevatedButton(
                                            // DYNAMIC RENDERING BLOCK: Toggles display presentation state dynamically based on item data statuses
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isBlocked
                                                  ? Colors.green
                                                  : Colors.red.shade800,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () => _toggleSingleBlock(
                                              matricId,
                                              currentStatus,
                                            ),
                                            child: Text(
                                              isBlocked ? 'UNBLOCK' : 'BLOCK',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
}
