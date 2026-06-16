import 'package:flutter/material.dart';
import 'package:sams/domain/samsactivityclaimmodel.dart';

// Controller class for managing curriculum activity claim data
// Uses ChangeNotifier to notify UI whenever data changes occur
class SAMSActivityClaimController extends ChangeNotifier {

  // List that stores all activity claim records
  List<SAMSActivityClaimModel> claims = [];

  // Add a new activity claim into the claim list
  void addClaim(SAMSActivityClaimModel claim) {

    // Insert claim object into list
    claims.add(claim);

    // Notify listeners to refresh the user interface
    notifyListeners();
  }

  // Update claim status
  // Example statuses:
  // PENDING
  // APPROVED
  // REJECTED
  void updateStatus(int index, String newStatus) {

    // Update selected claim status
    claims[index].status = newStatus;

    // Notify listeners that data has changed
    notifyListeners();
  }

  // Delete activity claim record
  void deleteClaim(int index) {

    // Remove claim from list using index position
    claims.removeAt(index);

    // Notify listeners to update the UI
    notifyListeners();
  }

  // Return total number of claims
  int getTotalClaims() {
    return claims.length;
  }

  // Return total approved claims
  int getApprovedClaims() {
    return claims
        .where((claim) => claim.status == 'APPROVED')
        .length;
  }

  // Return total pending claims
  int getPendingClaims() {
    return claims
        .where((claim) => claim.status == 'PENDING')
        .length;
  }

  // Return total rejected claims
  int getRejectedClaims() {
    return claims
        .where((claim) => claim.status == 'REJECTED')
        .length;
  }
}
