class VerifyResetOtpRequest {
  final String email;
  final String otp;

  VerifyResetOtpRequest({
    required this.email,
    required this.otp,
  });

  factory VerifyResetOtpRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return VerifyResetOtpRequest(
      email: json['email']?.toString().trim() ?? '',
      otp: json['otp']?.toString().trim() ?? '',
    );
  }
}