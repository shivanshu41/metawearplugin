# MetaWear iOS Plugin

This is the iOS implementation of the MetaWear plugin for Capacitor, providing sensor fusion capabilities for MetaWear devices.

## Features

- Connect to MetaWear devices via Bluetooth
- Start/stop sensor fusion streaming
- Receive real-time sensor data including:
  - Accelerometer data (corrected)
  - Gyroscope data (corrected)
  - Magnetometer data (corrected)
  - Quaternion data
- Disconnect from devices

## Installation

The plugin is automatically included when you add the MetaWear plugin to your Capacitor project.

### Dependencies

The plugin requires the following dependencies:
- MetaWear iOS SDK (v4.0.0+)
- Capacitor iOS (v7.0.0+)

## Usage

### Connect to a MetaWear Device

```typescript
import { MetaWear } from 'metawear';

// Connect to device using MAC address or UUID
await MetaWear.connect({ deviceId: 'C8:DF:84:8E:66:B9' });
```

### Start Sensor Fusion

```typescript
// Start sensor fusion streaming
await MetaWear.startSensorFusion();
```

### Listen to Sensor Data

```typescript
import { addSensorListener } from 'metawear';

// Add listener for sensor data
addSensorListener((data) => {
  console.log('Sensor data:', data);
  // Data includes: timestamp, xAccl, yAccl, zAccl, xGyr, yGyr, zGyr, xMag, yMag, zMag, xQuat, yQuat, zQuat, wQuat
});
```

### Stop Sensor Fusion

```typescript
// Stop sensor fusion streaming
await MetaWear.stopSensorFusion();
```

### Disconnect

```typescript
// Disconnect from device
await MetaWear.disconnect();
```

## API Reference

### Methods

#### `connect(options: { deviceId: string })`
Connects to a MetaWear device using the provided device ID (MAC address or UUID).

#### `startSensorFusion()`
Starts sensor fusion streaming. This will begin sending sensor data events.

#### `stopSensorFusion()`
Stops sensor fusion streaming.

#### `disconnect()`
Disconnects from the MetaWear device.

### Events

#### `sensorData`
Emitted when new sensor data is available. The event data includes:

- `timestamp`: Timestamp of the data
- `xAccl`, `yAccl`, `zAccl`: Accelerometer values (corrected)
- `xGyr`, `yGyr`, `zGyr`: Gyroscope values (corrected)
- `xMag`, `yMag`, `zMag`: Magnetometer values (corrected)
- `xQuat`, `yQuat`, `zQuat`, `wQuat`: Quaternion values
- `counter`: Incremental counter for data points
- `date`: Date string

## Configuration

The sensor fusion is configured with the following settings according to the [MetaWear documentation](https://mbientlab.netlify.app/documentation/MetaWear):
- Mode: NDOF (Nine Degrees of Freedom)
- Sensor fusion automatically handles accelerometer and gyroscope ranges
- Orientation reset is performed before starting

## Error Handling

The plugin provides detailed error messages for common issues:
- Invalid device ID
- Device not connected
- Sensor fusion module not available
- Connection failures

## Permissions

Make sure your iOS app has the necessary Bluetooth permissions in the `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to MetaWear devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to connect to MetaWear devices</string>
```

## Troubleshooting

1. **Device not found**: Ensure the MetaWear device is powered on and in range
2. **Connection failed**: Check that Bluetooth is enabled and the device is not connected to another app
3. **No sensor data**: Verify that sensor fusion has been started after connecting

## Implementation Details

The iOS plugin uses the [MetaWear iOS SDK](https://mbientlab.netlify.app/documentation/MetaWear) to communicate with MetaWear devices. It implements the same interface as the Android version, ensuring cross-platform compatibility.

The plugin handles:
- Bluetooth device discovery and connection using `MetaWearScanner.shared.startScan()`
- Sensor fusion configuration and streaming with NDOF mode
- Data synchronization and event emission for all sensor types
- Proper cleanup and disconnection 