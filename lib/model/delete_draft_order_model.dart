class DeleteDraftOrderResponseModel {
  final Meta meta;

  DeleteDraftOrderResponseModel({required this.meta});

  factory DeleteDraftOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteDraftOrderResponseModel(
      meta: Meta.fromJson(json['meta']),
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
