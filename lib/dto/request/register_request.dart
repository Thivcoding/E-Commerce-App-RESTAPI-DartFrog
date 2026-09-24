class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  factory RegisterRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RegisterRequest(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      confirmPassword: json['confirmPassword']?.toString() ?? '',
    );
  }
}
