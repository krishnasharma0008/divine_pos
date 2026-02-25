class DivineFeedbackModel {
  // Step 1 – customer part
  final double experienceRating; // Q1
  final String discoverySource; // Q2
  final String customerType; // Q3
  final String occasion; // Q4
  final String customerName; // Q5
  final String mobileNumber; // Q6
  final String email; // Q7

  // Step 2 – sales part
  final String salesStaff; // Q8

  DivineFeedbackModel({
    required this.experienceRating,
    required this.discoverySource,
    required this.customerType,
    required this.occasion,
    required this.customerName,
    required this.mobileNumber,
    required this.email,
    required this.salesStaff,
  });

  Map<String, dynamic> toJson() => {
    'experience_rating': experienceRating,
    'discovery_source': discoverySource,
    'customer_type': customerType,
    'occasion': occasion,
    'customer_name': customerName,
    'mobile_number': mobileNumber,
    'email': email,
    'sales_staff': salesStaff,
  };
}
