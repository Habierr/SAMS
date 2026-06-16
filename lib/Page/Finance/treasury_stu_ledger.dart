import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// =============================================================================
// TreasuryStuLedger - Displays student's financial ledger with payment history
// Shows receipt records, running balances, and current semester fee status
// =============================================================================
class TreasuryStuLedger extends StatefulWidget {
  final String matricId; // Student ID passed from previous selection screen

  const TreasuryStuLedger({super.key, required this.matricId});

  @override
  State<TreasuryStuLedger> createState() => _TreasuryStuLedgerState();
}

class _TreasuryStuLedgerState extends State<TreasuryStuLedger> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // Custom gradient app bar with student management title
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
        // Fetch student profile first, then load receipt stream
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.matricId)
              .get(),
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!studentSnapshot.hasData || !studentSnapshot.data!.exists) {
              return const Center(
                child: Text('Student profile data not found.'),
              );
            }

            final studentData =
                studentSnapshot.data!.data() as Map<String, dynamic>;

            // Stream receipts sorted chronologically (oldest to newest)
            // This ensures running balance calculation is accurate
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.matricId)
                  .collection('receipts')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, receiptSnapshot) {
                // Accumulators for summary totals
                double totalReceivedAllSemesters = 0.0;
                double currentSemReceivedAccumulator = 0.0;
                double totalRefundAccumulator = 0.0;
                List<QueryDocumentSnapshot> receiptDocs = [];

                if (receiptSnapshot.hasData) {
                  receiptDocs = receiptSnapshot.data!.docs;
                  for (var doc in receiptDocs) {
                    final rData = doc.data() as Map<String, dynamic>;
                    double amount =
                        double.tryParse(rData['totalReceived'].toString()) ??
                            0.0;
                    String semStr = (rData['semester'] ?? '').toString();
                    double refund =
                        double.tryParse((rData['refund'] ?? 0.0).toString()) ??
                            0.0;

                    totalReceivedAllSemesters += amount;
                    totalRefundAccumulator += refund;

                    // Track current semester payments specifically
                    if (semStr == 'SEM II 25/26' || semStr == 'SEM 2 25/26') {
                      currentSemReceivedAccumulator += amount;
                    }
                  }
                }

                // Calculate remaining fee for current semester (1510 fixed fee)
                double calculatedCurrentTotalFee =
                    1510.0 - currentSemReceivedAccumulator;
                if (calculatedCurrentTotalFee < 0)
                  calculatedCurrentTotalFee = 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page title
                      const Center(
                        child: Text(
                          'Student Ledger',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Student information section
                      _buildLedgerRow('Name', studentData['name'] ?? 'N/A'),
                      _buildLedgerRow('Matric ID', widget.matricId),
                      _buildLedgerRow('Email', studentData['email'] ?? 'N/A'),
                      _buildLedgerRow(
                        'Contact Number',
                        studentData['contact'] ?? 'N/A',
                      ),
                      _buildStatusRow('Status', studentData['status'] ?? 'N/A'),
                      _buildLedgerRow(
                        'Sponsor',
                        studentData['sponsor'] ?? 'NONE',
                      ),
                      _buildLedgerRow(
                        'Bank Number',
                        studentData['bankNumber'] ?? 'N/A',
                      ),
                      _buildLedgerRow('Bank', studentData['bankName'] ?? 'N/A'),
                      _buildFeeRow(
                        'Current Total Fee',
                        'RM ${calculatedCurrentTotalFee.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 32),

                      // Payment history table
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade400),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.3),
                          3: FlexColumnWidth(1.3),
                          4: FlexColumnWidth(1.0),
                          5: FlexColumnWidth(1.0),
                        },
                        children: [
                          // Table header row
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                            ),
                            children: const [
                              _TableCellHeader('Receipt No.'),
                              _TableCellHeader('Semester'),
                              _TableCellHeader('Payment Date'),
                              _TableCellHeader('Total Received'),
                              _TableCellHeader('Balance'),
                              _TableCellHeader('Refund'),
                            ],
                          ),
                          // Receipt rows with rolling balance calculation
                          ...(() {
                            // Running balance starts at full semester fee
                            double runningSem2FeeBalance = 1510.0;

                            return receiptDocs.map((doc) {
                              final receiptNo = doc.id;
                              final rData = doc.data() as Map<String, dynamic>;
                              double singleReceived = double.tryParse(
                                    rData['totalReceived'].toString(),
                                  ) ??
                                  0.0;
                              String semStr =
                                  (rData['semester'] ?? '').toString();
                              final String? docUrlString = rData['documentUrl'];

                              double displayRowBalance = 0.0;

                              // Only calculate running balance for current semester
                              if (semStr == 'SEM II 25/26' ||
                                  semStr == 'SEM 2 25/26') {
                                runningSem2FeeBalance -= singleReceived;
                                displayRowBalance = runningSem2FeeBalance;
                              } else {
                                // Historical records show 0 balance
                                displayRowBalance = 0.00;
                              }

                              if (displayRowBalance < 0)
                                displayRowBalance = 0.0;

                              return TableRow(
                                children: [
                                  // Receipt number - clickable to open document
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: InkWell(
                                      onTap: () async {
                                        if (docUrlString != null &&
                                            docUrlString.isNotEmpty) {
                                          final Uri urlValue = Uri.parse(
                                            docUrlString,
                                          );
                                          if (await canLaunchUrl(urlValue)) {
                                            await launchUrl(
                                              urlValue,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Could not open document.',
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Receipt #$receiptNo has no attachment.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          receiptNo,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  _TableCellText(rData['semester'] ?? ''),
                                  _TableCellText(rData['paymentDate'] ?? ''),
                                  _TableCellText(
                                    singleReceived.toStringAsFixed(2),
                                  ),
                                  _TableCellText(
                                    displayRowBalance.toStringAsFixed(2),
                                    color: Colors.red,
                                  ),
                                  _TableCellText(
                                    double.parse(
                                      (rData['refund'] ?? 0.0).toString(),
                                    ).toStringAsFixed(2),
                                    color: Colors.red,
                                  ),
                                ],
                              );
                            }).toList();
                          })(),
                          // Footer summary row with totals
                          TableRow(
                            children: [
                              const TableCell(child: SizedBox()),
                              const TableCell(child: SizedBox()),
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              _TableCellText(
                                totalReceivedAllSemesters.toStringAsFixed(2),
                                isBold: true,
                              ),
                              _TableCellText(
                                calculatedCurrentTotalFee.toStringAsFixed(2),
                                isBold: true,
                                color: Colors.red,
                              ),
                              _TableCellText(
                                totalRefundAccumulator.toStringAsFixed(2),
                                isBold: true,
                                color: Colors.red,
                              ),
                            ],
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
    );
  }

  // ---------------------------------------------------------------------------
  // Helper: Standard row builder for student info display
  // ---------------------------------------------------------------------------
  Widget _buildLedgerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper: Fee row with red colored amount display
  // ---------------------------------------------------------------------------
  Widget _buildFeeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper: Status row with color coding (green = NOT BLOCKED, red = BLOCKED)
  // ---------------------------------------------------------------------------
  Widget _buildStatusRow(String label, String value) {
    String cleanValue = value.trim().toUpperCase();
    Color statusColor = Colors.grey;

    if (cleanValue == 'NOT BLOCKED') {
      statusColor = Colors.green;
    } else if (cleanValue == 'BLOCKED') {
      statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _TableCellHeader - Bold header cell for table columns
// =============================================================================
class _TableCellHeader extends StatelessWidget {
  final String text;
  const _TableCellHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// =============================================================================
// _TableCellText - Standard table cell with optional bold and color styling
// =============================================================================
class _TableCellText extends StatelessWidget {
  final String text;
  final bool isBold;
  final Color color;
  const _TableCellText(
    this.text, {
    this.isBold = false,
    this.color = Colors.black87,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
