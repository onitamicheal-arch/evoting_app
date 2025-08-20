# eVoting App - Troubleshooting Guide

## 🚨 Common Build Failures and Solutions

### 1. **"Flutter not recognized"**
**Error**: `'flutter' is not recognized as an internal or external command`

**Solutions**:
1. **Install Flutter SDK**:
   - Download: https://flutter.dev/docs/get-started/install/windows
   - Extract to `C:\flutter`
   - Add `C:\flutter\bin` to your system PATH
   - Restart terminal/PowerShell

2. **Verify Installation**:
   ```bash
   flutter doctor
   flutter --version
   ```

### 2. **Dependency Version Conflicts**
**Error**: Version solving failed, package conflicts

**Solutions**:
1. **Use the fix script**: `fix_build.bat`
2. **Manual fix**:
   ```bash
   flutter clean
   flutter pub get
   ```
3. **Use stable versions**: Copy `pubspec_stable.yaml` to `pubspec.yaml`

### 3. **MissingPluginException (Toast)**
**Error**: `MissingPluginException(No implementation found for method showToast)`

**Solutions**:
1. **Full rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
2. **Alternative**: The app has fallback to SnackBar messages
3. **Remove fluttertoast**: Comment out fluttertoast in pubspec.yaml

### 4. **Gradle Build Failures**
**Error**: Gradle build failed, Android build issues

**Solutions**:
1. **Update Android SDK**: Update through Android Studio
2. **Clean gradle cache**:
   ```bash
   cd android
   gradlew clean
   cd ..
   flutter clean
   flutter run
   ```
3. **Check Java version**: Ensure JDK 11 or later is installed

### 5. **Import/Package Not Found**
**Error**: `Target of URI doesn't exist`, package import errors

**Solutions**:
1. **Check pubspec.yaml**: Ensure all dependencies are listed
2. **Regenerate pubspec.lock**:
   ```bash
   rm pubspec.lock
   flutter pub get
   ```
3. **IDE restart**: Restart your IDE/editor

## 🛠️ Quick Fix Commands

### Option 1: Automated Fix
```bash
# Run the comprehensive fix script
fix_build.bat
```

### Option 2: Manual Steps
```bash
# Step 1: Clean everything
flutter clean
rm -rf build/
rm -rf .dart_tool/

# Step 2: Get dependencies
flutter pub get

# Step 3: Run
flutter run
```

### Option 3: Minimal Dependencies
If you're still having issues, use minimal dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  go_router: ^12.1.3
  provider: ^6.1.1
  sqflite: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 📱 Platform-Specific Issues

### Windows
- Ensure Windows SDK is installed
- Check Windows Defender isn't blocking Flutter
- Run PowerShell as Administrator if needed

### Android
- Update Android SDK through Android Studio
- Ensure Android device is connected and debugging enabled
- Check minimum SDK version (21+)

### iOS (if applicable)
- Xcode must be installed and updated
- iOS Simulator or physical device needed
- Check iOS deployment target (11.0+)

## 🔍 Diagnostic Commands

Run these to identify issues:

```bash
# Check Flutter installation
flutter doctor -v

# Check project analysis
flutter analyze

# Verbose dependency resolution
flutter pub get --verbose

# Check connected devices
flutter devices
```

## 📞 Getting Help

If none of these solutions work:

1. **Share the exact error message** - Copy the full error output
2. **Include system info**:
   ```bash
   flutter doctor -v
   ```
3. **Specify what you were doing** when the error occurred

## 🎯 Demo Credentials

For testing the app:

**Admin Login**:
- Email: `admin@evoting.com`
- Password: `admin123`

**User Registration**: Fill out the form with any valid data
- VIN must be exactly 19 characters
- Email must be valid format
- Phone must be 10+ digits

## 📋 File Reference

- `fix_build.bat` - Comprehensive fix script
- `setup.bat` - General setup script  
- `pubspec_stable.yaml` - Known working dependencies
- `pubspec_backup.yaml` - Backup of your original file
- `admin_login_screen_simple.dart` - Simplified admin login
- `message_utils.dart` - Fallback message handling

## 🚀 Alternative Approach

If you continue having build issues, you can:

1. Create a new Flutter project: `flutter create evoting_new`
2. Copy the working files from this project
3. Use the minimal dependencies approach
4. Gradually add features back

Remember: The core functionality works - the issues are typically dependency-related and can be resolved with proper setup!
