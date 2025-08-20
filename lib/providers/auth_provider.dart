import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/admin.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  Admin? get currentAdmin => _authService.currentAdmin;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isUserLoggedIn => _authService.isUserLoggedIn;
  bool get isAdminLoggedIn => _authService.isAdminLoggedIn;

  // User registration
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String vin,
    required String phoneNumber,
    required String password,
  }) async {
    final result = await _authService.registerUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      vin: vin,
      phoneNumber: phoneNumber,
      password: password,
    );
    
    if (result['success']) {
      notifyListeners();
    }
    
    return result;
  }

  // User login step 1 (surname/password)
  Future<Map<String, dynamic>> loginUserStep1({
    required String surname,
    required String password,
  }) async {
    final result = await _authService.loginUserStep1(
      surname: surname,
      password: password,
    );
    
    if (result['success'] && !result['requiresBiometric']) {
      notifyListeners();
    }
    
    return result;
  }

  // User login step 2 (biometric)
  Future<Map<String, dynamic>> loginUserStep2Biometric(User user) async {
    final result = await _authService.loginUserStep2Biometric(user);
    
    if (result['success']) {
      notifyListeners();
    }
    
    return result;
  }

  // Check biometric availability
  Future<Map<String, dynamic>> checkBiometricAvailability() async {
    return await _authService.checkBiometricAvailability();
  }

  // Enable biometric
  Future<Map<String, dynamic>> enableBiometric() async {
    final result = await _authService.enableBiometric();
    
    if (result['success']) {
      notifyListeners();
    }
    
    return result;
  }

  // Admin login
  Future<Map<String, dynamic>> loginAdmin({
    required String username,
    required String password,
  }) async {
    final result = await _authService.loginAdmin(
      username: username,
      password: password,
    );
    
    if (result['success']) {
      notifyListeners();
    }
    
    return result;
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  // Check if user has voted in election
  Future<bool> hasUserVoted(int electionId) async {
    return await _authService.hasUserVoted(electionId);
  }
}
