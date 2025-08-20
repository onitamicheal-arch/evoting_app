class Admin {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  Admin({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.role = 'admin',
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin?.millisecondsSinceEpoch,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'],
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
      role: map['role'] ?? 'admin',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLogin: map['lastLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'])
          : null,
    );
  }

  Admin copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return Admin(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
