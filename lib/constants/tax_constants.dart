class TaxConstants {
  // GST Percentages
  static const double gstPercent = 3.0;
  static const double engravingGstPercent = 18.0;

  // Engraving Cost
  static const double engravingCostPerItem = 1000.0;

  // Your GST Number (if needed for invoices)
  static const String gstNumber = "YOUR_GST_NUMBER_HERE";

  // Helper methods for calculations
  static double calculateGst(double amount) {
    return amount * (gstPercent / 100);
  }

  static double calculateEngravingGst(double engravingAmount) {
    return engravingAmount * (engravingGstPercent / 100);
  }

  static double calculateGrandTotal({
    required double subtotal,
    required double engravingCost,
  }) {
    final gst = calculateGst(subtotal);
    final engravingGst = calculateEngravingGst(engravingCost);
    return subtotal + engravingCost + engravingGst + gst;
  }
}
