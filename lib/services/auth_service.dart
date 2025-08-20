import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:email_validator/email_validator.dart';
import '../models/user.dart';
import '../models/admin.dart';
import 'database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? _currentUser;
  Admin? _currentAdmin;

  User? get currentUser => _currentUser;
  Admin? get currentAdmin => _currentAdmin;
  bool get isLoggedIn => _currentUser != null || _currentAdmin != null;
  bool get isUserLoggedIn => _currentUser != null;
  bool get isAdminLoggedIn => _currentAdmin != null;

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Validate VIN format (19 alphanumeric characters)
  bool _isValidVin(String vin) {
    final vinRegex = RegExp(r'^[A-Z0-9]{19}$');
    return vinRegex.hasMatch(vin.toUpperCase());
  }

  // Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  // User Registration
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String vin,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Validation
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return {'success': false, 'message': 'First name and last name are required'};
      }

      if (!EmailValidator.validate(email)) {
        return {'success': false, 'message': 'Invalid email format'};
      }

      if (!_isValidVin(vin)) {
        return {'success': false, 'message': 'VIN must be exactly 19 alphanumeric characters'};
      }

      if (!_isValidPhoneNumber(phoneNumber)) {
        return {'success': false, 'message': 'Invalid phone number format'};
      }

      if (password.length < 6) {
        return {'success': false, 'message': 'Password must be at least 6 characters long'};
      }

      // Check if user already exists
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        return {'success': false, 'message': 'User with this email already exists'};
      }

      final existingVin = await _dbHelper.getUserByVin(vin.toUpperCase());
      if (existingVin != null) {
        return {'success': false, 'message': 'User with this VIN already exists'};
      }

      // Create user
      final user = User(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.toLowerCase().trim(),
        vin: vin.toUpperCase(),
        phoneNumber: phoneNumber.trim(),
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
      );

      final userId = await _dbHelper.insertUser(user);
      if (userId > 0) {
        return {'success': true, 'message': 'Registration successful', 'userId': userId};
      } else {
        return {'success': false, 'message': 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Registration error: ${e.toString()}'};
    }
  }

  // User Login (Step 1: LastName/Password)
  Future<Map<String, dynamic>> loginUserStep1({
    required String surname,
    required String password,
  }) async {
    try {
      if (surname.trim().isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Last name and password are required'};
      }

      final user = await _dbHelper.getUserByLastName(surname.trim());
      if (user == null) {
        return {'success': false, 'message': 'User not found'};
      }

      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        return {'success': false, 'message': 'Invalid password'};
      }

      // Check if biometric is enabled
      if (user.biometricEnabled) {
        return {
          'success': true,
          'requiresBiometric': true,
          'user': user,
          'message': 'Password verified, biometric authentication required'
        };
      } else {
        // Complete login without biometric
        _currentUser = user.copyWith(lastLogin: DateTime.now());
        await _dbHelper.updateUser(_currentUser!);
        return {'success': true, 'requiresBiometric': false, 'user': _currentUser};
      }
    } catch (e) {
      return {'success': false, 'message': 'Login error: ${e.toString()}'};
    }
  }

  // Check biometric availability
  Future<Map<String, dynamic>> checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return {'success': false, 'message': 'Biometric authentication not available'};
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      return {
        'success': true,
        'hasFingerprint': availableBiometrics.contains(BiometricType.fingerprint),
        'hasFace': availableBiometrics.contains(BiometricType.face),
        'available': availableBiometrics,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error checking biometric availability: ${e.toString()}'};
    }
  }

  // User Login (Step 2: Biometric)
  Future<Map<String, dynamic>> loginUserStep2Biometric(User user) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to complete login',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        _currentUser = user.copyWith(lastLogin: DateTime.now());
        await _dbHelper.updateUser(_currentUser!);
        return {'success': true, 'user': _currentUser};
      } else {
        return {'success': false, 'message': 'Biometric authentication failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Biometric authentication error: ${e.toString()}'};
    }
  }

  // Enable biometric for user
  Future<Map<String, dynamic>> enableBiometric() async {
    try {
      if (_currentUser == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      final biometricCheck = await checkBiometricAvailability();
      if (!biometricCheck['success']) {
        return biometricCheck;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        _currentUser = _currentUser!.copyWith(biometricEnabled: true);
        await _dbHelper.updateUser(_currentUser!);
        return {'success': true, 'message': 'Biometric authentication enabled'};
      } else {
        return {'success': false, 'message': 'Biometric setup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error enabling biometric: ${e.toString()}'};
    }
  }

  // Admin Login
  Future<Map<String, dynamic>> loginAdmin({
    required String username,
    required String password,
  }) async {
    try {
      if (username.trim().isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Username and password are required'};
      }

      final admin = await _dbHelper.getAdminByUsername(username.trim());
      if (admin == null) {
        return {'success': false, 'message': 'Admin not found'};
      }

      final hashedPassword = _hashPassword(password);
      if (admin.passwordHash != hashedPassword) {
        return {'success': false, 'message': 'Invalid password'};
      }

      _currentAdmin = admin.copyWith(lastLogin: DateTime.now());
      await _dbHelper.updateAdmin(_currentAdmin!);
      return {'success': true, 'admin': _currentAdmin};
    } catch (e) {
      return {'success': false, 'message': 'Admin login error: ${e.toString()}'};
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _currentAdmin = null;
  }

  // Check if user has voted in an election
  Future<bool> hasUserVoted(int electionId) async {
    if (_currentUser == null) return false;
    
    final vote = await _dbHelper.getUserVoteForElection(_currentUser!.id!, electionId);
    return vote != null;
  }
}
