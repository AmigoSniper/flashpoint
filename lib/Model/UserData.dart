import 'package:salescheck/Model/User.dart';

class UserData {
  final String token;
  final User user;

  UserData({required this.token, required this.user});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}
