class ResetPasswordRequest {
  final String email;
  final String resetToken;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.resetToken,
    required this.newPassword,
  });

  factory ResetPasswordRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResetPasswordRequest(
      email: json['email']?.toString().trim() ?? '',
      resetToken: json['resetToken']?.toString().trim() ?? '',
      newPassword: json['newPassword']?.toString() ?? '',
    );
  }
}