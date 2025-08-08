class ChangePasswordResponse {
  final Meta meta;
  final dynamic data;

  ChangePasswordResponse({required this.meta, this.data});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      meta: Meta.fromJson(json['meta']),
      data: json['data'],
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
