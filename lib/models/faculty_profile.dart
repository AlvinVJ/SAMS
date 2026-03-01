class AssignedClass {
  final String className;
  final String batchName;
  final String role;

  AssignedClass({
    required this.className,
    required this.batchName,
    required this.role,
  });

  factory AssignedClass.fromJson(Map<String, dynamic> json) {
    return AssignedClass(
      className: json['className'] ?? '',
      batchName: json['batchName'] ?? '',
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
  final String? hodOf;

  FacultyProfile({
    required this.mitsUid,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.assignedClasses,
    required this.roles,
    this.hodOf,
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
      hodOf: json['hodOf'],
    );
  }
}
