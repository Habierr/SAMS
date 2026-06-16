import 'package:flutter/material.dart';
import 'package:sams/domain/samsactivityclaimmodel.dart';

// Controller class for managing activity claim records
// Uses ChangeNotifier to update UI automatically when data changes
class SAMSActivityClaimController extends ChangeNotifier {

  // List to store all activity claim records
  List<SAMSActivityClaimModel> claims = [];

  // Add a new activity claim into the list
  void addClaim(SAMSActivityClaimModel claim) {
    claims.add(claim);

    // Notify listeners to refresh UI
    notifyListeners();
  }

  // Update claim status (e.g., Pending, Approved, Rejected)
  void updateStatus(int index, String newStatus) {

    // Update selected claim status
    claims[index].status = newStatus;

    // Notify listeners about data changes
    notifyListeners();
  }

  // Delete a claim record from the list
  void deleteClaim(int index) {

    // Remove claim based on index
    claims.removeAt(index);

    // Notify listeners to update UI
    notifyListeners();
  }
}
