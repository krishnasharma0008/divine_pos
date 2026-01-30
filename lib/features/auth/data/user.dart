class User {
  final int userid;
  final String userName;
  final String displayName;
  final String designation;
  final String token;
  final String pjcode;
  final int cartCount;

  const User({
    required this.userid,
    required this.userName,
    required this.displayName,
    required this.designation,
    required this.token,
    required this.pjcode,
    required this.cartCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userid: json['userid'] ?? 0,
      userName: json['username'] ?? '',
      displayName: json['dpname'] ?? '',
      designation: json['designation'] ?? '',
      token: json['token'] ?? '',
      pjcode: json['pjcode'] ?? '',
      cartCount: json['cartcount'] ?? 0, // ✅ FIX
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'username': userName,
      'dpname': displayName,
      'designation': designation,
      'token': token,
      'pjcode': pjcode,
      'cartcount': cartCount,
    };
  }

  User copyWith({int? cartCount}) {
    return User(
      userid: userid,
      userName: userName,
      displayName: displayName,
      designation: designation,
      token: token,
      pjcode: pjcode,
      cartCount: cartCount ?? this.cartCount,
    );
  }
}
