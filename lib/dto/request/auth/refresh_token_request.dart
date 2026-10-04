class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RefreshTokenRequest(
      refreshToken: json['refreshToken']?.toString().trim() ?? '',
    );
  }
}
