class DivineFeedbackModel {
  // Step 1 – customer part
  final int? orderno;
  final String customer_type; // Q3
  final String customer_name; // Q5
  final String contact_no; // Q6
  final String email; // Q7
  final int experience_rating; // Q1
  final String discovery_source; // Q2
  final String occasion; // Q4

  // Step 2 – sales part
  final String sales_by; // Q8

  DivineFeedbackModel({
    required this.orderno,
    required this.customer_type,
    required this.customer_name,
    required this.contact_no,
    required this.email,
    required this.experience_rating,
    required this.discovery_source,
    required this.occasion,
    required this.sales_by,
  });

  Map<String, dynamic> toJson() => {
    'orderno': orderno,
    'customer_type': customer_type,
    'customer_name': customer_name,
    'contact_no': contact_no,
    'email': email,
    'experience_rating': experience_rating,
    'discovery_source': discovery_source,
    'occasion': occasion,
    'sales_by': sales_by,
  };
}
