# MetaWear Capacitor Plugin

A Capacitor plugin for MetaWear sensor fusion and BLE communication, supporting both iOS and Android platforms.

## Features

- **Sensor Fusion**: NDOF (Nine Degrees of Freedom) sensor fusion
- **Real-time Data Streaming**: Continuous sensor data streaming to JavaScript
- **Cross-platform**: Works on both iOS and Android
- **Local Dependencies**: Uses local SDK files for offline development
- **TypeScript Support**: Full TypeScript definitions included

## Installation

### Prerequisites

- Node.js 16+
- Capacitor 7+
- iOS: Xcode 14+ (macOS only)
- Android: Android Studio, Java 11+

### Quick Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd metawear
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up local SDK dependencies**
   ```bash
   # On macOS/Linux
   chmod +x setup-local-sdk.sh
   ./setup-local-sdk.sh
   
   # On Windows
   setup-local-sdk.bat
   ```

4. **Build the plugin**
   ```bash
   npm run build
   ```

## Local SDK Setup

This plugin uses **local dependencies** instead of external package managers for better offline development and version control.

### iOS Setup

1. **Download MetaWear iOS SDK**
   - Visit: https://mbientlab.com/developers/metawear/ios/
   - Download the latest `MetaWear.framework`

2. **Place in project**
   ```
   metawear/ios/Frameworks/
   └── MetaWear.framework/
       ├── MetaWear
       ├── Info.plist
       ├── Modules/
       └── Headers/
   ```

3. **Install pods**
   ```bash
   cd ios
   pod install
   cd ..
   ```

### Android Setup

1. **Download MetaWear Android SDK**
   - Visit: https://mbientlab.com/developers/metawear/android/
   - Download the latest AAR files

2. **Place in project**
   ```
   metawear/android/libs/
   ├── metawear-4.0.0.aar
   └── bletoolbox-scanner-0.3.2.aar
   ```

3. **Sync Gradle**
   ```bash
   cd android
   ./gradlew clean build
   cd ..
   ```

## Usage

### JavaScript/TypeScript

```typescript
import { MetaWear, addSensorListener } from 'metawear';

// Connect to device
await MetaWear.connect({ deviceId: 'your-device-id' });

// Start sensor fusion
await MetaWear.startSensorFusion();

// Listen for sensor data
addSensorListener((data) => {
  console.log('Sensor data:', data);
  // data contains: timestamp, xAccl, yAccl, zAccl, xGyr, yGyr, zGyr, xMag, yMag, zMag, xQuat, yQuat, zQuat, wQuat
});

// Stop and disconnect
await MetaWear.stopSensorFusion();
await MetaWear.disconnect();
```

### React Component Example

```tsx
import React, { useEffect, useState } from 'react';
import { MetaWear, addSensorListener } from 'metawear';

const MetaWearComponent = () => {
  const [isConnected, setIsConnected] = useState(false);
  const [sensorData, setSensorData] = useState(null);

  useEffect(() => {
    addSensorListener((data) => {
      setSensorData(data);
    });
  }, []);

  const connect = async () => {
    try {
      await MetaWear.connect({ deviceId: 'your-device-id' });
      setIsConnected(true);
    } catch (error) {
      console.error('Connection failed:', error);
    }
  };

  const startStreaming = async () => {
    try {
      await MetaWear.startSensorFusion();
    } catch (error) {
      console.error('Start failed:', error);
    }
  };

  return (
    <div>
      <button onClick={connect} disabled={isConnected}>
        Connect
      </button>
      <button onClick={startStreaming} disabled={!isConnected}>
        Start Streaming
      </button>
      {sensorData && (
        <pre>{JSON.stringify(sensorData, null, 2)}</pre>
      )}
    </div>
  );
};
```

## API Reference

### Methods

- `connect(options: { deviceId: string }): Promise<{ success: boolean }>`
- `startSensorFusion(): Promise<void>`
- `stopSensorFusion(): Promise<void>`
- `disconnect(): Promise<void>`

### Events

- `sensorData`: Fired when new sensor data is available

### Data Structure

```typescript
interface SensorData {
  timestamp: number;      // Unix timestamp in milliseconds
  date: string;          // Human-readable date string
  counter: number;       // Incremental counter
  xAccl: number;         // Accelerometer X-axis (g)
  yAccl: number;         // Accelerometer Y-axis (g)
  zAccl: number;         // Accelerometer Z-axis (g)
  xGyr: number;          // Gyroscope X-axis (°/s)
  yGyr: number;          // Gyroscope Y-axis (°/s)
  zGyr: number;          // Gyroscope Z-axis (°/s)
  xMag: number;          // Magnetometer X-axis (µT)
  yMag: number;          // Magnetometer Y-axis (µT)
  zMag: number;          // Magnetometer Z-axis (µT)
  xQuat: number;         // Quaternion X component
  yQuat: number;         // Quaternion Y component
  zQuat: number;         // Quaternion Z component
  wQuat: number;         // Quaternion W component
}
```

## Development

### Build Commands

```bash
# Build the plugin
npm run build

# Watch for changes
npm run watch

# Verify builds
npm run verify:ios      # iOS build verification
npm run verify:android  # Android build verification
npm run verify          # Both platforms
```

### Project Structure

```
metawear/
├── src/                    # TypeScript source
│   ├── definitions.ts     # Type definitions
│   ├── index.ts          # Main export
│   └── web.ts            # Web implementation
├── ios/                   # iOS native code
│   ├── Sources/          # Swift source files
│   ├── Frameworks/       # Local iOS frameworks
│   └── Tests/            # iOS tests
├── android/               # Android native code
│   ├── src/main/java/    # Java source files
│   └── libs/             # Local AAR files
├── dist/                  # Built output
└── package.json           # Package configuration
```

## Benefits of Local Dependencies

- **Offline Development**: No internet required for builds
- **Version Control**: Exact SDK versions tracked in repository
- **Build Stability**: Consistent builds across environments
- **CI/CD Friendly**: Reliable automated builds
- **Customization**: Ability to modify SDK if needed

## Troubleshooting

### Common Issues

1. **Framework not found**
   - Ensure MetaWear.framework is in `ios/Frameworks/`
   - Check framework architecture matches target

2. **Build errors**
   - Clean build: `cd ios && xcodebuild clean`
   - Reinstall pods: `pod install --repo-update`

3. **Linking issues**
   - Verify framework compatibility with iOS target
   - Check all required frameworks are listed

### Support

- Check the [MetaWear documentation](https://mbientlab.com/docs/)
- Review [Capacitor plugin development guide](https://capacitorjs.com/docs/plugins)
- Open an issue for plugin-specific problems

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Changelog

### v0.0.1
- Initial release
- iOS and Android support
- Sensor fusion implementation
- Local dependency support
