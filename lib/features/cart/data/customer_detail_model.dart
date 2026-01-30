class CustomerDetail {
  final int? id;
  final String name;
  final String address;
  final String contactNo;
  final String pan;
  final String gender;
  final String dob;
  final String pincode;
  final String email;

  const CustomerDetail({
    this.id,
    required this.name,
    required this.address,
    required this.contactNo,
    required this.pan,
    required this.gender,
    required this.dob,
    required this.pincode,
    required this.email,
  });

  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    return CustomerDetail(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      contactNo: json['contactno'] as String? ?? '',
      pan: json['pan'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contactno': contactNo,
      'pan': pan,
      'gender': gender,
      'dob': dob,
      'pincode': pincode,
      'email': email,
    };
  }
}
