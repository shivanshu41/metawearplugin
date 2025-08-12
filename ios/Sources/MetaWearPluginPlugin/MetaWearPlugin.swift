import Foundation
import MetaWear
import CoreBluetooth

@objc public class MetaWearPlugin: NSObject {
    private var device: MetaWear?
    private var sensorFusion: SensorFusionBosch?
    private var dataMap: [String: Any] = [:]
    private var counter: Int64 = 0
    private var useSensorDataClass: Bool = false
    private weak var plugin: MetaWearPluginPlugin?
    private var isStreaming: Bool = false
    private var lastEmissionTime: TimeInterval = 0
    private let minEmissionInterval: TimeInterval = 0.01 // 10ms minimum between emissions
    
    @objc public override init() {
        super.init()
    }
    
    @objc public func setPlugin(_ plugin: MetaWearPluginPlugin) {
        self.plugin = plugin
    }
    
    @objc public func setUseSensorDataClass(_ value: Bool) {
        self.useSensorDataClass = value
        print("Set useSensorDataClass = \(value)")
    }
    
    @objc public func connect(deviceId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // For iOS, we need to scan and connect to the device
        // The deviceId should be the MAC address or UUID
        MetaWearScanner.shared.startScan(allowDuplicates: false) { device in
            if device.mac == deviceId || device.identifier.uuidString == deviceId {
                MetaWearScanner.shared.stopScan()
                self.device = device
                
                // Connect and setup the device
                device.connectAndSetup().continue { task in
                    if let error = task.error {
                        print("Board connection failed: \(error)")
                        completion(.failure(error))
                    } else {
                        print("Board connected successfully")
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    @objc public func startSensorFusion(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let device = device, device.isConnected else {
            completion(.failure(MetaWearError.deviceNotConnected))
            return
        }
        
        sensorFusion = device.sensorFusion
        guard let fusion = sensorFusion else {
            completion(.failure(MetaWearError.sensorFusionNotAvailable))
            return
        }
        
        do {
            print("Configuring sensor fusion...")
            
            // Configure sensor fusion according to MetaWear documentation
            fusion.configure(mode: .ndof)
            
            // Reset orientation
            fusion.resetOrientation()
            
            // Clear any existing data
            dataMap.removeAll()
            counter = 0
            lastEmissionTime = 0
            
            // Setup data handlers for continuous streaming
            setupAccelerometerHandler(fusion)
            setupGyroscopeHandler(fusion)
            setupMagnetometerHandler(fusion)
            setupQuaternionHandler(fusion)
            
            // Start sensor fusion
            fusion.start()
            isStreaming = true
            
            print("SensorFusion started.")
            completion(.success(()))
            
        } catch {
            print("SensorFusion start error: \(error)")
            completion(.failure(error))
        }
    }
    
    private func setupAccelerometerHandler(_ fusion: SensorFusionBosch) {
        fusion.correctedAcceleration?.startNotifications { acceleration in
            DispatchQueue.main.async {
                if self.isStreaming {
                    self.dataMap["acc"] = acceleration
                    self.checkAndEmit(timestamp: Date().timeIntervalSince1970 * 1000)
                }
            }
        }
    }
    
    private func setupGyroscopeHandler(_ fusion: SensorFusionBosch) {
        fusion.correctedAngularVelocity?.startNotifications { angularVelocity in
            DispatchQueue.main.async {
                if self.isStreaming {
                    self.dataMap["gyro"] = angularVelocity
                    self.checkAndEmit(timestamp: Date().timeIntervalSince1970 * 1000)
                }
            }
        }
    }
    
    private func setupMagnetometerHandler(_ fusion: SensorFusionBosch) {
        fusion.correctedMagneticField?.startNotifications { magneticField in
            DispatchQueue.main.async {
                if self.isStreaming {
                    self.dataMap["mag"] = magneticField
                    self.checkAndEmit(timestamp: Date().timeIntervalSince1970 * 1000)
                }
            }
        }
    }
    
    private func setupQuaternionHandler(_ fusion: SensorFusionBosch) {
        fusion.quaternion?.startNotifications { quaternion in
            DispatchQueue.main.async {
                if self.isStreaming {
                    self.dataMap["quat"] = quaternion
                    self.checkAndEmit(timestamp: Date().timeIntervalSince1970 * 1000)
                }
            }
        }
    }
    
    private func checkAndEmit(timestamp: Double) {
        guard isStreaming,
              let acc = dataMap["acc"] as? SensorFusionBosch.CorrectedAcceleration,
              let gyro = dataMap["gyro"] as? SensorFusionBosch.CorrectedAngularVelocity,
              let mag = dataMap["mag"] as? SensorFusionBosch.CorrectedMagneticField,
              let quat = dataMap["quat"] as? SensorFusionBosch.Quaternion else {
            return
        }
        
        // Rate limiting to prevent too frequent emissions
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastEmissionTime < minEmissionInterval {
            return
        }
        
        // Clear the data map after collecting all sensor data
        dataMap.removeAll()
        
        counter += 1
        let date = Date()
        lastEmissionTime = currentTime
        
        // Create sensor data structure that matches Android implementation
        let sensorData: [String: Any] = [
            "timestamp": timestamp,
            "date": date.description,
            "counter": counter,
            "xAccl": acc.x,
            "yAccl": acc.y,
            "zAccl": acc.z,
            "xGyr": gyro.x,
            "yGyr": gyro.y,
            "zGyr": gyro.z,
            "xMag": mag.x,
            "yMag": mag.y,
            "zMag": mag.z,
            "xQuat": quat.x,
            "yQuat": quat.y,
            "zQuat": quat.z,
            "wQuat": quat.w
        ]
        
        print("SensorData: \(sensorData)")
        
        // Send the event to JavaScript via the plugin bridge
        plugin?.sendSensorEvent(event: "sensorData", data: sensorData)
    }
    
    @objc public func stopSensorFusion(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let fusion = sensorFusion else {
            completion(.success(()))
            return
        }
        
        isStreaming = false
        
        // Stop all sensor streams
        fusion.correctedAcceleration?.stopNotifications()
        fusion.correctedAngularVelocity?.stopNotifications()
        fusion.correctedMagneticField?.stopNotifications()
        fusion.quaternion?.stopNotifications()
        
        fusion.stop()
        
        // Clear data
        dataMap.removeAll()
        
        print("SensorFusion stopped")
        completion(.success(()))
    }
    
    @objc public func disconnect(completion: @escaping (Result<Void, Error>) -> Void) {
        print("Trying to disconnect from MetaWear board")
        guard let device = device else {
            completion(.failure(MetaWearError.deviceNotConnected))
            return
        }
        
        // Stop streaming if active
        if isStreaming {
            isStreaming = false
            dataMap.removeAll()
        }
        
        device.disconnect().continue { task in
            if let error = task.error {
                print("Disconnect error: \(error)")
                completion(.failure(error))
            } else {
                print("Disconnected from MetaWear board")
                completion(.success(()))
            }
        }
    }
}

// Custom error types
enum MetaWearError: Error, LocalizedError {
    case invalidDeviceId
    case deviceNotConnected
    case sensorFusionNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .invalidDeviceId:
            return "Invalid device ID"
        case .deviceNotConnected:
            return "Device not connected"
        case .sensorFusionNotAvailable:
            return "Sensor fusion module not available"
        }
    }
}
