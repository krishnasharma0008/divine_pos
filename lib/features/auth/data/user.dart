class User {
  final int userid;
  final String userName;
  final String displayName;
  final String designation;
  final String token;
  final String pjcode;

  User({
    required this.userid,
    required this.userName,
    required this.displayName,
    required this.designation,
    required this.token,
    required this.pjcode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userid: json['userid'] ?? 0,
      userName: json['username'] ?? '',
      displayName: json['dpname'] ?? '',
      designation: json['designation'] ?? '',
      token: json['token'] ?? '',
      pjcode: json['pjcode'] ?? '',
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
    };
  }
}
