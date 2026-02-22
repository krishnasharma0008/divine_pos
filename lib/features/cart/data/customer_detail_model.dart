class CustomerDetail {
  final int? id;
  final String? name;
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
    this.address = '',
    this.contactNo = '',
    this.pan = '',
    this.gender = '',
    this.dob = '',
    this.pincode = '',
    this.email = '',
  });

  CustomerDetail copyWith({
    int? id,
    String? name,
    String? address,
    String? contactNo,
    String? pan,
    String? gender,
    String? dob,
    String? pincode,
    String? email,
  }) {
    return CustomerDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      contactNo: contactNo ?? this.contactNo,
      pan: pan ?? this.pan,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      pincode: pincode ?? this.pincode,
      email: email ?? this.email,
    );
  }

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
