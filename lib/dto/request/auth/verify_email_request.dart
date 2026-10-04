class VerifyEmailRequest {
  final String email;
  final String otp;

  VerifyEmailRequest({
    required this.email,
    required this.otp,
  });

  factory VerifyEmailRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return VerifyEmailRequest(
      email: json['email']?.toString().trim() ?? '',
      otp: json['otp']?.toString().trim() ?? '',
    );
  }
}