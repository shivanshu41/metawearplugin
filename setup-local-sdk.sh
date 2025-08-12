#!/bin/bash

# MetaWear Local SDK Setup Script
# This script helps set up local dependencies for the MetaWear plugin

set -e

echo "🚀 Setting up MetaWear Local SDK Dependencies..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS for iOS development
check_ios_requirements() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Checking iOS development requirements..."
        
        # Check if Xcode is installed
        if ! command -v xcodebuild &> /dev/null; then
            print_error "Xcode is not installed. Please install Xcode from the App Store."
            exit 1
        fi
        
        # Check if CocoaPods is installed
        if ! command -v pod &> /dev/null; then
            print_warning "CocoaPods is not installed. Installing..."
            sudo gem install cocoapods
        fi
        
        print_success "iOS development requirements met"
    else
        print_warning "Not running on macOS. iOS development setup skipped."
    fi
}

# Check if running on Linux/Windows for Android development
check_android_requirements() {
    print_status "Checking Android development requirements..."
    
    # Check if Java is installed
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed. Please install Java 11 or later."
        exit 1
    fi
    
    # Check if Android SDK is available
    if [ -z "$ANDROID_HOME" ]; then
        print_warning "ANDROID_HOME is not set. Please set it to your Android SDK path."
        print_status "Example: export ANDROID_HOME=/path/to/android/sdk"
    else
        print_success "Android SDK found at: $ANDROID_HOME"
    fi
    
    print_success "Android development requirements met"
}

# Download MetaWear iOS SDK
download_ios_sdk() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Setting up iOS MetaWear SDK..."
        
        IOS_FRAMEWORKS_DIR="ios/Frameworks"
        
        if [ ! -d "$IOS_FRAMEWORKS_DIR/MetaWear.framework" ]; then
            print_warning "MetaWear.framework not found in $IOS_FRAMEWORKS_DIR"
            print_status "Please download the MetaWear iOS SDK from:"
            print_status "https://mbientlab.com/developers/metawear/ios/"
            print_status "And place MetaWear.framework in $IOS_FRAMEWORKS_DIR/"
            
            # Create placeholder directory
            mkdir -p "$IOS_FRAMEWORKS_DIR"
            print_status "Created placeholder directory: $IOS_FRAMEWORKS_DIR"
        else
            print_success "MetaWear.framework found in $IOS_FRAMEWORKS_DIR"
        fi
    fi
}

# Download MetaWear Android SDK
download_android_sdk() {
    print_status "Setting up Android MetaWear SDK..."
    
    ANDROID_LIBS_DIR="android/libs"
    
    if [ ! -f "$ANDROID_LIBS_DIR/metawear-4.0.0.aar" ]; then
        print_warning "MetaWear Android AAR not found in $ANDROID_LIBS_DIR"
        print_status "Please download the MetaWear Android SDK from:"
        print_status "https://mbientlab.com/developers/metawear/android/"
        print_status "And place the AAR files in $ANDROID_LIBS_DIR/"
        
        # Create placeholder directory
        mkdir -p "$ANDROID_LIBS_DIR"
        print_status "Created placeholder directory: $ANDROID_LIBS_DIR"
    else
        print_success "MetaWear Android AAR found in $ANDROID_LIBS_DIR"
    fi
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Install npm dependencies
    if [ -f "package.json" ]; then
        print_status "Installing npm dependencies..."
        npm install
    fi
    
    # Install iOS pods if on macOS
    if [[ "$OSTYPE" == "darwin"* ]] && [ -f "ios/Podfile" ]; then
        print_status "Installing iOS pods..."
        cd ios
        pod install
        cd ..
    fi
    
    print_success "Dependencies installed successfully"
}

# Build the plugin
build_plugin() {
    print_status "Building MetaWear plugin..."
    
    if npm run build; then
        print_success "Plugin built successfully"
    else
        print_error "Plugin build failed"
        exit 1
    fi
}

# Main execution
main() {
    print_status "Starting MetaWear Local SDK setup..."
    
    # Check requirements
    check_ios_requirements
    check_android_requirements
    
    # Download SDKs
    download_ios_sdk
    download_android_sdk
    
    # Install dependencies
    install_dependencies
    
    # Build plugin
    build_plugin
    
    print_success "MetaWear Local SDK setup completed successfully!"
    print_status ""
    print_status "Next steps:"
    print_status "1. Ensure MetaWear.framework is in ios/Frameworks/"
    print_status "2. Ensure MetaWear AAR files are in android/libs/"
    print_status "3. Run 'npm run verify:ios' to test iOS build"
    print_status "4. Run 'npm run verify:android' to test Android build"
}

# Run main function
main "$@" 