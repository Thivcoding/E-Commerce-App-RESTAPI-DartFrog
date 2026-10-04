class LogoutRequest {
  final String refreshToken;

  LogoutRequest({
    required this.refreshToken,
  });

  factory LogoutRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return LogoutRequest(
      refreshToken: json['refreshToken']?.toString().trim() ?? '',
    );
  }
}
