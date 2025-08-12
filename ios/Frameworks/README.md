# Local MetaWear iOS SDK Setup

This directory contains local iOS frameworks for the MetaWear SDK to avoid external dependencies.

## Setup Instructions

### 1. Download MetaWear iOS SDK
Download the MetaWear iOS SDK from the official MetaWear website or repository:
- Visit: https://mbientlab.com/developers/metawear/ios/
- Download the latest iOS SDK (MetaWear.framework)

### 2. Place Framework Files
Place the downloaded `MetaWear.framework` in this directory:
```
metawear/ios/Frameworks/
├── MetaWear.framework/
│   ├── MetaWear
│   ├── Info.plist
│   ├── Modules/
│   └── Headers/
└── README.md
```

### 3. Verify Framework Structure
Ensure the framework contains:
- `MetaWear` binary file
- `Info.plist` with proper bundle identifier
- `Modules` directory with module map
- `Headers` directory with public headers

### 4. Build Configuration
The framework is automatically included via the podspec configuration:
```ruby
s.vendored_frameworks = 'ios/Frameworks/MetaWear.framework'
```

### 5. Alternative: Use Local Pod
If you prefer to use a local pod instead of vendored frameworks:

1. Create a local podspec for MetaWear:
```ruby
# MetaWear.podspec
Pod::Spec.new do |s|
  s.name = 'MetaWear'
  s.version = '4.0.0'
  s.source = { :path => '.' }
  s.source_files = 'MetaWear.framework/Headers/*.h'
  s.vendored_frameworks = 'MetaWear.framework'
  s.frameworks = 'CoreBluetooth', 'CoreMotion'
end
```

2. Update the main podspec:
```ruby
s.dependency 'MetaWear', :path => './ios/Frameworks'
```

## Benefits of Local Dependencies

- **Offline Development**: No need for internet connection during builds
- **Version Control**: Exact SDK version is tracked in your repository
- **Build Stability**: No dependency on external package managers
- **Customization**: Ability to modify SDK if needed
- **CI/CD**: Consistent builds across different environments

## Troubleshooting

### Framework Not Found
- Ensure the framework path is correct in podspec
- Check that the framework is properly signed
- Verify the framework architecture matches your target

### Build Errors
- Clean build folder: `cd ios && xcodebuild clean`
- Reinstall pods: `pod install --repo-update`
- Check framework compatibility with iOS deployment target

### Linking Issues
- Ensure all required frameworks are listed in podspec
- Check that the framework supports your target architecture
- Verify the framework is compatible with your Xcode version 