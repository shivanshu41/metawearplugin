package com.wellmetrix.metawear;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "MetaWear")
public class MetaWearPlugin extends Plugin {

    private MetaWearService metaWear;

    @Override
    public void load() {
        metaWear = new MetaWearService(this);
    }

    // ✅ Public method to allow MetaWearService to send events
    public void sendSensorEvent(String event, JSObject data) {
        notifyListeners(event, data);
    }

    @PluginMethod
    public void connect(PluginCall call) {
        String deviceId = call.getString("deviceId");
        if (deviceId == null) {
            call.reject("Missing deviceId");
            return;
        }
        metaWear.connect(deviceId, call);
    }

    @PluginMethod
    public void startSensorFusion(PluginCall call) {
        metaWear.startSensorFusion(call);
    }

    @PluginMethod
    public void stopSensorFusion(PluginCall call) {
        metaWear.stopSensorFusion(call);
    }

    @PluginMethod
    public void disconnect(PluginCall call) {
        metaWear.disconnect(call);
    }
}
