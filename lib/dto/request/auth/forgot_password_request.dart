class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  factory ForgotPasswordRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return ForgotPasswordRequest(
      email: json['email']?.toString().trim() ?? '',
    );
  }
}