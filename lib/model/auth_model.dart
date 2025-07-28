class LoginResponse {
  final Data data;
  final bool success;
  final String message;
  final String timestamp;

  LoginResponse({
    required this.data,
    required this.success,
    required this.message,
    required this.timestamp,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      data: Data.fromJson(json['data']),
      success: json['success'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}

class Data {
  final User user;
  final String token;

  Data({
    required this.user,
    required this.token,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}

class User {
  final int idUser;
  final String role;
  final String fullName;
  final String username;

  User({
    required this.idUser,
    required this.role,
    required this.fullName,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['idUser'],
      role: json['role'],
      fullName: json['fullName'],
      username: json['username'],
    );
  }
}
