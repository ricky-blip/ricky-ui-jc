class LoginResponseModel {
  final Meta meta;
  final LoginData data;

  LoginResponseModel({
    required this.meta,
    required this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      meta: Meta.fromJson(json['meta']),
      data: LoginData.fromJson(json['data']),
    );
  }
}

class Meta {
  final int code;
  final String status;
  final String message;
  final String timestamp;

  Meta({
    required this.code,
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      code: json['code'],
      status: json['status'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}

class LoginData {
  final User user;
  final String token;

  LoginData({
    required this.user,
    required this.token,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
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
