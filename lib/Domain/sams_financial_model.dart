class SAMSFinancialModel {
  final String paymentID;
  final int receiptID;
  final String feeID;
  final double studentFeeBalance;
  final bool studentAccessStatus;
  final double paymentTotal;
  final String paymentDetails;

  const SAMSFinancialModel({
    required this.paymentID,
    required this.receiptID,
    required this.feeID,
    required this.studentFeeBalance,
    required this.studentAccessStatus,
    required this.paymentTotal,
    required this.paymentDetails,
  });

  // Converts the data structure into a Map to save to Firebase easily
  Map<String, dynamic> toMap() {
    return {
      'paymentID': paymentID,
      'receiptID': receiptID,
      'feeID': feeID,
      'studentFeeBalance': studentFeeBalance,
      'studentAccessStatus': studentAccessStatus,
      'paymentTotal': paymentTotal,
      'paymentDetails': paymentDetails,
    };
  }

  // Factory constructor to build a model from a database record snapshot map safely
  factory SAMSFinancialModel.fromMap(Map<String, dynamic> map) {
    return SAMSFinancialModel(
      paymentID: map['paymentID'] ?? '',
      receiptID: int.tryParse(map['receiptID'].toString()) ?? 0,
      feeID: map['feeID'] ?? '',
      studentFeeBalance:
          double.tryParse(map['studentFeeBalance'].toString()) ?? 0.0,
      studentAccessStatus: map['studentAccessStatus'] ?? false,
      paymentTotal: double.tryParse(map['paymentTotal'].toString()) ?? 0.0,
      paymentDetails: map['paymentDetails'] ?? '',
    );
  }
}
