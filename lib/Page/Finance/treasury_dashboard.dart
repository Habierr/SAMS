import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Handles automated day and date calculations
import '../../login.dart';
import './stu_finance_rec_list.dart';
import './unpaidstulist.dart';

class TreasuryDashboard extends StatelessWidget {
  const TreasuryDashboard({super.key});

  // Dynamic helper logic to scan and count how many students currently owe money
  Future<int> _countUnsettledStudents() async {
    final studentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    int unsettledCount = 0;

    for (var doc in studentSnapshot.docs) {
      final receiptSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(doc.id)
          .collection('receipts')
          .get();

      double semReceived = 0.0;
      for (var rDoc in receiptSnapshot.docs) {
        final rData = rDoc.data();
        if (rData['semester'] == 'SEM 2 25/26') {
          semReceived +=
              double.tryParse(rData['totalReceived'].toString()) ?? 0.0;
        }
      }

      double balance = 1510.0 - semReceived;
      if (balance > 0) {
        unsettledCount++;
      }
    }

    return unsettledCount;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // Generates current calendar values automatically (e.g., "MONDAY | 13/04/2026")
    final String formattedDayDate = DateFormat(
      'EEEE | dd/MM/yyyy',
    ).format(DateTime.now()).toUpperCase();

    // Mock ID used for displaying the name greeting banner.
    // In production, you can pass the logged-in ID string here!
    const String activeStaffId = 'STAFF_TRE01';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),

      // 1. Treasury Styled Custom Header AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
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

      // Side Drawer Navigation Panel Options
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF988B0C)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF988B0C),
                  size: 36,
                ),
              ),
              accountName: const Text(
                'Treasury Officer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: const Text('treasury@umpsa.edu.my'),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF988B0C)),
              title: const Text('Home Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: Color(0xFF988B0C)),
              title: const Text('Unsettled Student Fees'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnpaidStuList(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Color(0xFF988B0C)),
              title: const Text('Student Financial Records'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentFinanceRecordsList(),
                  ),
                );
              },
            ),
            const Spacer(),
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // 2. Main White Content Canvas Layout
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
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(activeStaffId)
              .get(),
          builder: (context, staffSnapshot) {
            String staffFirstName = "Officer";

            if (staffSnapshot.hasData && staffSnapshot.data!.exists) {
              final staffData =
                  staffSnapshot.data!.data() as Map<String, dynamic>?;
              final fullName = staffData?['name'] ?? "Ahmad";
              // Extracts just the first name token string securely
              staffFirstName = fullName.toString().split(' ').first;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text Greet Section
                  Text(
                    'Welcome, Mr. $staffFirstName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calendar Time Stamp Text Display Row
                  Center(
                    child: Text(
                      formattedDayDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. THE GRADIENT SUMMARY CARD BLOCK DISPLAY CONTAINER
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFAC9C13),
                            Color(0xFFC7A76C),
                            Color(0xFFCB8574),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Students With\nUnsettled Fees',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // FutureBuilder dynamically calculates the badge counter total integer variable
                          FutureBuilder<int>(
                            future: _countUnsettledStudents(),
                            builder: (context, countSnapshot) {
                              if (countSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                );
                              }
                              final count = countSnapshot.data ?? 0;
                              return Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 4. QUICK REDIRECT NAVIGATION ANCHOR LINKS BUTTON STACK

                  // Button 1: Unsettled Student List Redirect
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UnpaidStuList(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18.0),
                        child: Center(
                          child: Text(
                            'List Of Unsettled\nStudent Fees',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button 2: General Ledger Archive Search Screen Redirect
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StudentFinanceRecordsList(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18.0),
                        child: Center(
                          child: Text(
                            'Student Financial\nRecord',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
