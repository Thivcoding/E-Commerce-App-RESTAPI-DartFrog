class UpdateCategoryRequest {
  final String name;
  final String description;
  final bool isActive;

  UpdateCategoryRequest({
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory UpdateCategoryRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return UpdateCategoryRequest(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}
