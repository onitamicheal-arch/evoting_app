# E-Voting Mobile App

A secure digital voting application built with Flutter that supports biometric authentication and comprehensive election management.

## Features

### User Features ✅
- **Secure Registration**: Full name, email, 19-digit VIN, phone number, and password
- **Two-Step Authentication**: Surname/password + biometric verification
- **Biometric Support**: Facial recognition and fingerprint authentication
- **Secure Voting**: Vote casting with confirmation and integrity verification
- **Results Viewing**: Access to released election results
- **Vote History**: View personal voting history

### Admin Features ✅
- **Election Management**: Create, start, end elections
- **Party Management**: Add and remove parties/candidates
- **Time Control**: Set election start and end times
- **Results Control**: Release election results when ready
- **Statistics**: View voting statistics and analytics

### Security Features ✅
- **Password Hashing**: SHA-256 password encryption
- **Vote Integrity**: Cryptographic hash verification for votes
- **Duplicate Prevention**: One vote per user per election
- **Biometric Authentication**: Local device biometric verification
- **Database Security**: SQLite with proper relationships and constraints

## Architecture

### Backend Services
- **DatabaseHelper**: SQLite database operations
- **AuthService**: Authentication and user management
- **VotingService**: Vote casting and results management

### State Management
- **AuthProvider**: Authentication state using Provider pattern
- **ElectionProvider**: Election and voting state management

### Models
- **User**: User profile with biometric support
- **Admin**: Administrative users
- **Election**: Election data with status management
- **Party**: Political parties and candidates
- **Vote**: Secure vote records with integrity hashing

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.0+)
- Dart SDK
- Android Studio or VS Code
- Android/iOS device or emulator with biometric support

### Installation

1. **Setup dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the application:**
   ```bash
   flutter run
   ```

3. **Default Admin Credentials:**
   - Username: `admin`
   - Password: `admin123`

## Development Status

### ✅ Completed Backend Architecture
- Complete database design with SQLite
- Authentication system with biometric support
- Voting system with security features
- Admin panel functionality
- State management with Provider
- Routing and navigation

### 🔄 UI Implementation Needed
The following screens need full implementation:

1. **Registration Screen**: Complete form with validation
2. **Home Screen**: Dashboard showing available elections
3. **Voting Screen**: Party selection and voting interface
4. **Vote Confirmation**: Final vote confirmation
5. **Results Screen**: Election results display
6. **Admin Screens**: Full admin panel interface

### 📱 Currently Available
- ✅ Splash Screen: Complete with loading animation
- ✅ Login Screen: Full implementation with biometric support
- 🔄 Other screens: Basic placeholders implemented

## Security Implementation

1. **Authentication Security**:
   - SHA-256 password hashing
   - Device biometric verification
   - Two-step authentication process

2. **Vote Security**:
   - Cryptographic integrity verification
   - One vote per user per election
   - Secure vote storage

3. **Data Protection**:
   - Local SQLite database
   - Proper database relationships
   - Input validation and sanitization

## Usage Guide

### For Voters
1. Register with personal details and VIN
2. Login with surname/password + biometric
3. Vote in available elections
4. View results when released

### For Administrators
1. Login with admin credentials
2. Create and manage elections
3. Add/remove parties and candidates
4. Control election timing and result release

## Troubleshooting

### Toast Plugin Issues
If you encounter `MissingPluginException` for fluttertoast:

1. **Run the setup script**: Double-click `setup.bat` for automatic setup
2. **Manual cleanup**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
3. **Alternative**: The app includes fallback message handling that will use SnackBar if toast fails

### Common Issues

**"Flutter not recognized"**
- Ensure Flutter SDK is installed and added to PATH
- Download from: https://flutter.dev/docs/get-started/install/windows
- Add `C:\flutter\bin` to system PATH
- Restart terminal and run `flutter doctor`

**"Plugin not found"**
- Run `flutter clean` then `flutter pub get`
- Restart your IDE
- Try running on a different device/emulator

**"Registration/Admin Login not implemented"**
- These screens are now fully implemented!
- Registration includes full form validation
- Admin login includes secure authentication
- Home screen provides proper dashboard functionality

## Testing

Run tests with:
```bash
flutter test
```

## Next Steps

To complete the application:
1. Implement remaining UI screens
2. Add comprehensive form validation
3. Enhance admin interface
4. Add result visualization
5. Implement comprehensive testing

## Contributing

This is a demonstration project showcasing Flutter app architecture with secure voting features.
