import Foundation
import Capacitor
import MetaWear

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(MetaWear)
public class MetaWearPluginPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "MetaWear"
    public let jsName = "MetaWear"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "connect", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startSensorFusion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopSensorFusion", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "disconnect", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = MetaWearPlugin()

    override public func load() {
        super.load()
        implementation.setPlugin(self)
    }

    @objc func connect(_ call: CAPPluginCall) {
        let deviceId = call.getString("deviceId") ?? ""
        if deviceId.isEmpty {
            call.reject("Missing deviceId")
            return
        }
        implementation.connect(deviceId: deviceId) { result in
            switch result {
            case .success:
                let response = JSObject()
                response["success"] = true
                call.resolve(response)
            case .failure(let error):
                call.reject("Connect failed: \(error.localizedDescription)")
            }
        }
    }

    @objc func startSensorFusion(_ call: CAPPluginCall) {
        implementation.startSensorFusion { result in
            switch result {
            case .success:
                call.resolve()
            case .failure(let error):
                call.reject("Start sensor fusion failed: \(error.localizedDescription)")
            }
        }
    }

    @objc func stopSensorFusion(_ call: CAPPluginCall) {
        implementation.stopSensorFusion { result in
            switch result {
            case .success:
                call.resolve()
            case .failure(let error):
                call.reject("Stop sensor fusion failed: \(error.localizedDescription)")
            }
        }
    }

    @objc func disconnect(_ call: CAPPluginCall) {
        implementation.disconnect { result in
            switch result {
            case .success:
                call.resolve()
            case .failure(let error):
                call.reject("Disconnect failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Public method to allow MetaWearPlugin to send events
    public func sendSensorEvent(event: String, data: [String: Any]) {
        // Convert the data to a proper format for JavaScript
        let jsData = JSObject()
        
        // Map all the sensor data fields
        if let timestamp = data["timestamp"] as? Double {
            jsData["timestamp"] = timestamp
        }
        if let date = data["date"] as? String {
            jsData["date"] = date
        }
        if let counter = data["counter"] as? Int64 {
            jsData["counter"] = counter
        }
        if let xAccl = data["xAccl"] as? Float {
            jsData["xAccl"] = xAccl
        }
        if let yAccl = data["yAccl"] as? Float {
            jsData["yAccl"] = yAccl
        }
        if let zAccl = data["zAccl"] as? Float {
            jsData["zAccl"] = zAccl
        }
        if let xGyr = data["xGyr"] as? Float {
            jsData["xGyr"] = xGyr
        }
        if let yGyr = data["yGyr"] as? Float {
            jsData["yGyr"] = yGyr
        }
        if let zGyr = data["zGyr"] as? Float {
            jsData["zGyr"] = zGyr
        }
        if let xMag = data["xMag"] as? Float {
            jsData["xMag"] = xMag
        }
        if let yMag = data["yMag"] as? Float {
            jsData["yMag"] = yMag
        }
        if let zMag = data["zMag"] as? Float {
            jsData["zMag"] = zMag
        }
        if let xQuat = data["xQuat"] as? Float {
            jsData["xQuat"] = xQuat
        }
        if let yQuat = data["yQuat"] as? Float {
            jsData["yQuat"] = yQuat
        }
        if let zQuat = data["zQuat"] as? Float {
            jsData["zQuat"] = zQuat
        }
        if let wQuat = data["wQuat"] as? Float {
            jsData["wQuat"] = wQuat
        }
        
        // Send the event to JavaScript
        notifyListeners(event, data: jsData)
    }
}
