import 'package:flutter/material.dart';
import 'package:sams/domain/samsactivityclaimmodel.dart';

class SAMSActivityClaimController extends ChangeNotifier {
  List<SAMSActivityClaimModel> claims = [];

  void addClaim(SAMSActivityClaimModel claim) {
    claims.add(claim);
    notifyListeners();
  }

  void updateStatus(int index, String newStatus) {
    claims[index].status = newStatus;
    notifyListeners();
  }

  void deleteClaim(int index) {
    claims.removeAt(index);
    notifyListeners();
  }
}