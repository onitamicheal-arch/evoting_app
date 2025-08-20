class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String vin; // 19 digit alphanumeric
  final String phoneNumber;
  final String passwordHash;
  final bool biometricEnabled;
  final String? biometricData; // Store biometric template if needed
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.vin,
    required this.phoneNumber,
    required this.passwordHash,
    this.biometricEnabled = false,
    this.biometricData,
    required this.createdAt,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'vin': vin,
      'phoneNumber': phoneNumber,
      'passwordHash': passwordHash,
      'biometricEnabled': biometricEnabled ? 1 : 0,
      'biometricData': biometricData,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin?.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      vin: map['vin'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
      biometricEnabled: (map['biometricEnabled'] ?? 0) == 1,
      biometricData: map['biometricData'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLogin: map['lastLogin'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'])
          : null,
    );
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? vin,
    String? phoneNumber,
    String? passwordHash,
    bool? biometricEnabled,
    String? biometricData,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      vin: vin ?? this.vin,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      passwordHash: passwordHash ?? this.passwordHash,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricData: biometricData ?? this.biometricData,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
