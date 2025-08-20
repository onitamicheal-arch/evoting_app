@echo off
echo ================================================
echo       eVoting App - Build Fix Script
echo ================================================
echo.

echo [1/7] Checking for Flutter...
where flutter >nul 2>nul
if %errorlevel%==0 (
    echo ✓ Flutter found!
    flutter --version
) else (
    echo ✗ Flutter not found in PATH!
    echo.
    echo Please install Flutter first:
    echo 1. Download: https://flutter.dev/docs/get-started/install/windows
    echo 2. Extract to C:\flutter
    echo 3. Add C:\flutter\bin to PATH
    echo 4. Restart terminal and run this script again
    echo.
    pause
    exit /b 1
)

echo.
echo [2/7] Backing up current pubspec.yaml...
if exist pubspec.yaml (
    copy pubspec.yaml pubspec_backup.yaml >nul
    echo ✓ Backup created: pubspec_backup.yaml
) else (
    echo ✗ pubspec.yaml not found!
)

echo.
echo [3/7] Using stable dependency versions...
if exist pubspec_stable.yaml (
    copy pubspec_stable.yaml pubspec.yaml >nul
    echo ✓ Using stable pubspec.yaml
) else (
    echo ✗ pubspec_stable.yaml not found!
    echo Creating minimal pubspec.yaml...
    echo name: evoting_app > pubspec.yaml
    echo description: "A Flutter voting app" >> pubspec.yaml
    echo version: 1.0.0+1 >> pubspec.yaml
    echo environment: >> pubspec.yaml
    echo   sdk: '>=3.0.0 <4.0.0' >> pubspec.yaml
    echo dependencies: >> pubspec.yaml
    echo   flutter: >> pubspec.yaml
    echo     sdk: flutter >> pubspec.yaml
    echo   cupertino_icons: ^1.0.8 >> pubspec.yaml
    echo   go_router: ^12.1.3 >> pubspec.yaml
    echo   provider: ^6.1.1 >> pubspec.yaml
    echo   sqflite: ^2.3.0 >> pubspec.yaml
    echo   path: ^1.8.3 >> pubspec.yaml
    echo   local_auth: ^2.1.7 >> pubspec.yaml
    echo   email_validator: ^2.1.17 >> pubspec.yaml
    echo   fluttertoast: ^8.2.4 >> pubspec.yaml
    echo   intl: ^0.18.1 >> pubspec.yaml
    echo dev_dependencies: >> pubspec.yaml
    echo   flutter_test: >> pubspec.yaml
    echo     sdk: flutter >> pubspec.yaml
    echo   flutter_lints: ^3.0.0 >> pubspec.yaml
    echo flutter: >> pubspec.yaml
    echo   uses-material-design: true >> pubspec.yaml
)

echo.
echo [4/7] Cleaning build cache...
if exist build\ (
    rmdir /s /q build
    echo ✓ Removed build directory
)

if exist .dart_tool\ (
    rmdir /s /q .dart_tool
    echo ✓ Removed .dart_tool directory
)

echo.
echo [5/7] Running flutter clean...
flutter clean
if %errorlevel%==0 (
    echo ✓ Flutter clean completed
) else (
    echo ✗ Flutter clean failed
)

echo.
echo [6/7] Getting dependencies...
flutter pub get
if %errorlevel%==0 (
    echo ✓ Dependencies installed successfully
) else (
    echo ✗ Failed to get dependencies
    echo.
    echo Try running manually:
    echo   flutter pub get --verbose
    echo.
    pause
    exit /b 1
)

echo.
echo [7/7] Running flutter doctor...
flutter doctor
echo.

echo ================================================
echo          Build Fix Complete!
echo ================================================
echo.
echo Next steps:
echo 1. If you see any issues with flutter doctor, fix them
echo 2. Try running: flutter run
echo 3. If build still fails, share the specific error message
echo.
echo Available files:
echo - pubspec_backup.yaml (your original file)
echo - pubspec_stable.yaml (stable versions)
echo - setup.bat (general setup)
echo.
pause
