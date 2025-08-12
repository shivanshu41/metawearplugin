@echo off
setlocal enabledelayedexpansion

echo 🚀 Setting up MetaWear Local SDK Dependencies...

REM Colors for output (Windows 10+ supports ANSI colors)
set "BLUE=[94m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

REM Function to print colored output
:print_status
echo %BLUE%[INFO]%NC% %~1
goto :eof

:print_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:print_error
echo %RED%[ERROR]%NC% %~1
goto :eof

call :print_status "Checking development requirements..."

REM Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    call :print_error "Java is not installed. Please install Java 11 or later."
    pause
    exit /b 1
)

REM Check if Android SDK is available
if "%ANDROID_HOME%"=="" (
    call :print_warning "ANDROID_HOME is not set. Please set it to your Android SDK path."
    call :print_status "Example: set ANDROID_HOME=C:\path\to\android\sdk"
) else (
    call :print_success "Android SDK found at: %ANDROID_HOME%"
)

call :print_success "Android development requirements met"

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    call :print_error "Node.js is not installed. Please install Node.js from https://nodejs.org/"
    pause
    exit /b 1
)

call :print_success "Node.js requirements met"

call :print_status "Setting up Android MetaWear SDK..."

set "ANDROID_LIBS_DIR=android\libs"

if not exist "%ANDROID_LIBS_DIR%\metawear-4.0.0.aar" (
    call :print_warning "MetaWear Android AAR not found in %ANDROID_LIBS_DIR%"
    call :print_status "Please download the MetaWear Android SDK from:"
    call :print_status "https://mbientlab.com/developers/metawear/android/"
    call :print_status "And place the AAR files in %ANDROID_LIBS_DIR%\"
    
    REM Create placeholder directory
    if not exist "%ANDROID_LIBS_DIR%" mkdir "%ANDROID_LIBS_DIR%"
    call :print_status "Created placeholder directory: %ANDROID_LIBS_DIR%"
) else (
    call :print_success "MetaWear Android AAR found in %ANDROID_LIBS_DIR%"
)

call :print_status "Installing dependencies..."

REM Install npm dependencies
if exist "package.json" (
    call :print_status "Installing npm dependencies..."
    npm install
    if %errorlevel% neq 0 (
        call :print_error "Failed to install npm dependencies"
        pause
        exit /b 1
    )
)

call :print_success "Dependencies installed successfully"

call :print_status "Building MetaWear plugin..."

REM Build the plugin
npm run build
if %errorlevel% neq 0 (
    call :print_error "Plugin build failed"
    pause
    exit /b 1
)

call :print_success "Plugin built successfully"

call :print_success "MetaWear Local SDK setup completed successfully!"
echo.
call :print_status "Next steps:"
call :print_status "1. Ensure MetaWear AAR files are in android\libs\"
call :print_status "2. Run 'npm run verify:android' to test Android build"
echo.
pause 