@echo off
echo Setting up eVoting Flutter project...
echo.

REM Check if Flutter is available in PATH
where flutter >nul 2>nul
if %errorlevel%==0 (
    echo Flutter found! Running setup commands...
    echo.
    
    echo Cleaning project...
    flutter clean
    echo.
    
    echo Getting dependencies...
    flutter pub get
    echo.
    
    echo Running build runner (if needed)...
    flutter packages pub run build_runner build --delete-conflicting-outputs 2>nul
    echo.
    
    echo Setup complete!
    echo You can now run: flutter run
) else (
    echo Flutter not found in PATH!
    echo.
    echo Please install Flutter SDK first:
    echo 1. Download from: https://flutter.dev/docs/get-started/install/windows
    echo 2. Extract to C:\flutter
    echo 3. Add C:\flutter\bin to your PATH
    echo 4. Run 'flutter doctor' to verify installation
    echo 5. Then run this script again
    echo.
    
    echo Attempting manual cleanup...
    if exist build\ rmdir /s /q build
    if exist .dart_tool\ rmdir /s /q .dart_tool
    echo Manual cleanup complete!
    echo.
    echo Please install Flutter SDK to complete setup.
)

echo.
pause
