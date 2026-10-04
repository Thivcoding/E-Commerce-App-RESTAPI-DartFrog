class CreateCategoryRequest {
  final String name;
  final String description;

  CreateCategoryRequest({
    required this.name,
    required this.description,
  });

  factory CreateCategoryRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateCategoryRequest(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
