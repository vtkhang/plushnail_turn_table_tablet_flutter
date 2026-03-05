enum UserRole {
  director,
  manager,
  receptionist,
  assistManager,
  employee;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'director': return UserRole.director;
      case 'manager': return UserRole.manager;
      case 'receptionist': return UserRole.receptionist;
      case 'assist_manager': return UserRole.assistManager;
      case 'employee': return UserRole.employee;
      default: return UserRole.employee;
    }
  }

  String toApiString() {
    switch (this) {
      case UserRole.director: return 'director';
      case UserRole.manager: return 'manager';
      case UserRole.receptionist: return 'receptionist';
      case UserRole.assistManager: return 'assist_manager';
      case UserRole.employee: return 'employee';
    }
  }
}

class User {
  final String id;
  final String name;
  final UserRole role;
  final int? salonId;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.salonId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    return User(
      id: userData['id'].toString(),
      name: userData['name'] ?? userData['username'] ?? '',
      role: UserRole.fromString(userData['role'] ?? 'employee'),
      salonId: userData['salon_id'] is int ? userData['salon_id'] : (userData['salon_id'] != null ? int.tryParse(userData['salon_id'].toString()) : null),
    );
  }
}
