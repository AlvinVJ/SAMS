class AssignedClass {
  final String className;
  final String role;

  AssignedClass({required this.className, required this.role});

  factory AssignedClass.fromJson(Map<String, dynamic> json) {
    return AssignedClass(
      className: json['className'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class FacultyProfile {
  final String mitsUid;
  final String name;
  final String email;
  final String department;
  final String designation;
  final List<AssignedClass> assignedClasses;
  final List<String> roles;

  FacultyProfile({
    required this.mitsUid,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.assignedClasses,
    required this.roles,
  });

  factory FacultyProfile.fromJson(Map<String, dynamic> json) {
    return FacultyProfile(
      mitsUid: json['mits_uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? 'Faculty Member',
      assignedClasses: (json['assignedClasses'] as List? ?? [])
          .map((i) => AssignedClass.fromJson(i))
          .toList(),
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
