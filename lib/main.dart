import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'Login.dart';

import 'package:sams/Page/lecturer/lecturer_dashboard.dart';
import 'package:sams/Page/lecturer/attendanceManagement.dart';
import 'package:sams/Page/lecturer/generateClassCode.dart';
import 'package:sams/Page/lecturer/classCodeList.dart';
import 'package:sams/Page/student/student_dashboard.dart';
import 'package:sams/Page/Faculty_reg/RegistrarDashboard.dart';
import 'package:sams/Page/pusat_adab/pusat_dashboard.dart';
import 'package:sams/Page/Finance/treasury_dashboard.dart';
import 'package:sams/Page/lecturer/attendanceRecord.dart';

import 'Provider/ORController.dart';
import 'Provider/sams_financial_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Map<String, dynamic> _getArgs(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ORController()),
        ChangeNotifierProvider(create: (_) => SAMSFinancialController()),
      ],
      child: MaterialApp(
        title: 'sams - SAMS',
        debugShowCheckedModeBanner: false,
        home: const Login(),
        routes: {
          '/login': (context) => const Login(),
          '/faculty_dashboard': (context) => const RegistrarDashboard(),
          '/lecturer_dashboard': (context) => const LecturerDashboard(
                lecturerName: '',
                lecturerId: '',
              ),
          '/pusat_dashboard': (context) => const PusatDashboard(),
          '/student_dashboard': (context) => const StudentDashboard(
                studentName: '',
                studentID: '',
                year: '',
                semester: '',
              ),
          '/treasury_dashboard': (context) => const TreasuryDashboard(),
          '/attendanceManagement': (context) {
            final args = _getArgs(context);

            return AttendanceManagement(
              lecturerName: args['lecturerName'] ?? '',
              lecturerId: args['lecturerId'] ?? '',
              regID: args['regID'] ?? '',
              subCode: args['subCode'] ?? '',
              subName: args['subName'] ?? '',
              classType: args['classType'] ?? '',
              sectionNo: args['sectionNo'] ?? '',
              day: args['day'] ?? '',
              startTime: args['startTime'] ?? '',
              endTime: args['endTime'] ?? '',
              semester: args['semester'] ?? '',
            );
          },
          '/generateClassCode': (context) {
            final args = _getArgs(context);

            return GenerateClassCode(
              lecturerName: args['lecturerName'] ?? '',
              lecturerId: args['lecturerId'] ?? '',
              regID: args['regID'] ?? '',
              subCode: args['subCode'] ?? '',
              subName: args['subName'] ?? '',
              classType: args['classType'] ?? '',
              sectionNo: args['sectionNo'] ?? '',
              day: args['day'] ?? '',
              startTime: args['startTime'] ?? '',
              endTime: args['endTime'] ?? '',
              semester: args['semester'] ?? '',
            );
          },
          '/classCodeList': (context) {
            final args = _getArgs(context);

            return ClassCodeList(
              lecturerName: args['lecturerName'] ?? '',
              lecturerId: args['lecturerId'] ?? '',
              regID: args['regID'] ?? '',
              subCode: args['subCode'] ?? '',
              subName: args['subName'] ?? '',
              classType: args['classType'] ?? '',
              sectionNo: args['sectionNo'] ?? '',
              day: args['day'] ?? '',
              startTime: args['startTime'] ?? '',
              endTime: args['endTime'] ?? '',
              semester: args['semester'] ?? '',
            );
          },
          '/attendanceRecord': (context) {
            final args = _getArgs(context);

            return AttendanceRecord(
              lecturerName: args['lecturerName'] ?? '',
              lecturerId: args['lecturerId'] ?? '',
              regID: args['regID'] ?? '',
              subCode: args['subCode'] ?? '',
              subName: args['subName'] ?? '',
              classType: args['classType'] ?? '',
              sectionNo: args['sectionNo'] ?? '',
              day: args['day'] ?? '',
              startTime: args['startTime'] ?? '',
              endTime: args['endTime'] ?? '',
              semester: args['semester'] ?? '',
            );
          },
        },
      ),
    );
  }
}
