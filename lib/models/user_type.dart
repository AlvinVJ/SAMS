class UserType {
  final int userTypeId;
  final String userTypeTag;
  final String? description;
  final bool isActive;

  UserType({
    required this.userTypeId,
    required this.userTypeTag,
    this.description,
    this.isActive = true,
  });

  factory UserType.fromJson(Map<String, dynamic> json) {
    return UserType(
      userTypeId: json['user_type_id'] ?? 0,
      userTypeTag: json['user_type_tag'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_type_id': userTypeId,
      'user_type_tag': userTypeTag,
      'description': description,
      'is_active': isActive,
    };
  }
}
