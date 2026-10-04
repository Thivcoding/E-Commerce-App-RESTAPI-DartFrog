class GoogleLoginRequest {
  final String idToken;

  GoogleLoginRequest({
    required this.idToken,
  });

  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) {
    return GoogleLoginRequest(
      idToken: json['idToken']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
    };
  }
}
