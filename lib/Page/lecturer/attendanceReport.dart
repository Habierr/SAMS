import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:sams/Page/lecturer/lecturer_dashboard.dart';

class AttendanceReport extends StatelessWidget {
  final String lecturerName;
  final String lecturerId;
  final String subCode;
  final String subName;
  final String sessionDate;
  final String section;
  final String sessionTime;
  final String classSession;

  const AttendanceReport({
    super.key,
    required this.lecturerName,
    required this.lecturerId,
    required this.subCode,
    required this.subName,
    required this.sessionDate,
    required this.section,
    required this.sessionTime,
    required this.classSession,
  });

  Future<QuerySnapshot> getReportData() {
    return FirebaseFirestore.instance
        .collection('attendanceReport')
        .where('subCode', isEqualTo: subCode)
        .where('sessionDate', isEqualTo: sessionDate)
        .where('sessionTime', isEqualTo: sessionTime)
        .where('classSession', isEqualTo: classSession)
        .get();
  }

  Future<QuerySnapshot> getAttendanceRecords() {
    return FirebaseFirestore.instance
        .collection('attendance')
        .where('subCode', isEqualTo: subCode)
        .where('sessionDate', isEqualTo: sessionDate)
        .where('sessionTime', isEqualTo: sessionTime)
        .where('classSession', isEqualTo: classSession)
        .get();
  }

  Future<Uint8List> generatePdf(
      Map<String, dynamic> report,
      List<QueryDocumentSnapshot> records,
      ) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load('assets/logo_umpsa.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    const darkBlue = PdfColor.fromInt(0xFF111B4D);
    const lightGreen = PdfColor.fromInt(0xFFF1F5EE);
    const lightBlue = PdfColor.fromInt(0xFFE6EDF9);
    const lightPresent = PdfColor.fromInt(0xFFDDF8D5);
    const lightAbsent = PdfColor.fromInt(0xFFFFE0E0);
    const purple = PdfColor.fromInt(0xFF5A00D6);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Image(logoImage, width: 65),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Attendance Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Student Academic Management System',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: lightGreen,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Text(
                        subName,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 17,
                          fontWeight: pw.FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _pdfInfo('Report ID', report['reportID'] ?? ''),
                    _pdfInfo('Date', sessionDate),
                    _pdfInfo('Section', section),
                    _pdfInfo('Class Time', sessionTime),
                    _pdfInfo('Session', classSession),
                    _pdfInfo('Report Date', report['reportDate'] ?? ''),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Row(
                children: [
                  _pdfSummaryCard(
                    'Students',
                    '${report['totalStudent'] ?? 0}',
                    lightBlue,
                    darkBlue,
                  ),
                  pw.SizedBox(width: 10),
                  _pdfSummaryCard(
                    'Present',
                    '${report['totalPresent'] ?? 0}',
                    lightPresent,
                    darkBlue,
                  ),
                  pw.SizedBox(width: 10),
                  _pdfSummaryCard(
                    'Absent',
                    '${report['totalAbsent'] ?? 0}',
                    lightAbsent,
                    darkBlue,
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                'Attendance List',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: darkBlue,
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.black),
                headerDecoration: const pw.BoxDecoration(
                  color: lightGreen,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: darkBlue,
                ),
                cellAlignment: pw.Alignment.center,
                cellStyle: const pw.TextStyle(fontSize: 11),
                cellPadding: const pw.EdgeInsets.all(8),
                headers: ['Student ID', 'Student Name', 'Status'],
                data: records.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return [
                    data['studentID'] ?? '',
                    data['studentName'] ?? '',
                    data['attendanceStatus'] ?? '',
                  ];
                }).toList(),
              ),

              pw.Spacer(),

              pw.Container(
                width: double.infinity,
                height: 4,
                color: purple,
              ),
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generated by SAMS',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: darkBlue,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryCard(
      String title,
      String value,
      PdfColor color,
      PdfColor textColor,
      ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: textColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2E9D13),
                    Color(0xFF5CB835),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo_umpsa.png', width: 55),
                    const SizedBox(height: 10),
                    const Text(
                      'STUDENT ACADEMIC\nMANAGEMENT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LecturerDashboard(
                      lecturerName: lecturerName,
                      lecturerId: lecturerId,
                    ),
                  ),
                );
              },
            ),

            const Spacer(),
            const Divider(),

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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              },
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,

          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),

          title: const Text(
            'STUDENT ACADEMIC\nMANAGEMENT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),

          centerTitle: true,

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                'assets/logo_umpsa.png',
                width: 45,
                height: 45,
              ),
            ),
          ],

          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2E9D13),
                  Color(0xFF5CB835),
                  Color(0xFF92DC5E),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
        ),
      ),

      body: FutureBuilder<List<QuerySnapshot>>(
        future: Future.wait([
          getReportData(),
          getAttendanceRecords(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading report:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final reportDocs = snapshot.data![0].docs;
          final attendanceDocs = snapshot.data![1].docs;

          if (reportDocs.isEmpty) {
            return const Center(
              child: Text('No report data found'),
            );
          }

          final report = reportDocs.last.data() as Map<String, dynamic>;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo_umpsa.png',
                    width: 55,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Attendance Report',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111B4D),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5EE),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            subName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111B4D),
                            ),
                          ),
                        ),

                        const SizedBox(height: 13),

                        _info('Report ID', report['reportID'] ?? ''),
                        _info('Date', sessionDate),
                        _info('Section', section),
                        _info('Class Time', sessionTime),
                        _info('Session', classSession),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _summaryCard(
                        title: 'Students',
                        value: (report['totalStudent'] ?? 0).toString(),
                        color: const Color(0xFFE6EDF9),
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        title: 'Present',
                        value: (report['totalPresent'] ?? 0).toString(),
                        color: const Color(0xFFDDF8D5),
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        title: 'Absent',
                        value: (report['totalAbsent'] ?? 0).toString(),
                        color: const Color(0xFFFFE0E0),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Attendance List',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111B4D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Table(
                    border: TableBorder.all(color: Colors.black87),
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.8),
                      2: FlexColumnWidth(1.1),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F5EE),
                        ),
                        children: [
                          _TableCell('Student ID', bold: true),
                          _TableCell('Student Name', bold: true),
                          _TableCell('Status', bold: true),
                        ],
                      ),

                      ...attendanceDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final status = data['attendanceStatus'] ?? '';

                        return TableRow(
                          children: [
                            _TableCell(data['studentID'] ?? ''),
                            _TableCell(data['studentName'] ?? ''),
                            _TableCell(
                              status,
                              color: status == 'Absent'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A00D6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Download Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () async {
                        final pdfBytes =
                        await generatePdf(report, attendanceDocs);

                        await Printing.layoutPdf(
                          onLayout: (format) async => pdfBytes,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF111B4D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111B4D),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111B4D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;

  const _TableCell(
      this.text, {
        this.bold = false,
        this.color,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: color ?? Colors.black,
        ),
      ),
    );
  }
}
