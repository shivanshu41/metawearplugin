package com.wellmetrix.metawear;

import android.bluetooth.BluetoothDevice;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;
import com.mbientlab.metawear.MetaWearBoard;
import com.mbientlab.metawear.android.BtleService;
import com.mbientlab.metawear.data.Quaternion;
import com.mbientlab.metawear.module.SensorFusionBosch;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

import bolts.Continuation;
import bolts.Task;

public class MetaWearService {
    private static final String TAG = "MetaWearService";
    private final MetaWearPlugin plugin;

    private BtleService.LocalBinder serviceBinder;
    private MetaWearBoard board;
    private SensorFusionBosch fusion;

    private final Map<String, Object> dataMap = new HashMap<>();
    private final AtomicLong counter = new AtomicLong(0);
    private boolean useSensorDataClass = false;

    public MetaWearService(MetaWearPlugin plugin) {
        this.plugin = plugin;
    }

    public void setUseSensorDataClass(boolean value) {
        this.useSensorDataClass = value;
        Log.i(TAG, "Set useSensorDataClass = " + value);
    }

    public void connect(String mac, PluginCall call) {
        Intent i = new Intent(plugin.getContext(), BtleService.class);
        plugin.getContext().bindService(i, new ServiceConnection() {
            @Override public void onServiceConnected(ComponentName name, IBinder binder) {
                serviceBinder = (BtleService.LocalBinder) binder;
                BluetoothDevice device = android.bluetooth.BluetoothAdapter.getDefaultAdapter().getRemoteDevice(mac);
                board = serviceBinder.getMetaWearBoard(device);

                Log.i(TAG, "Service connected. Connecting to MetaWear board...");
                board.connectAsync().continueWith((Continuation<Void, Void>) t -> {
                    if (t.isFaulted()) {
                        Log.e(TAG, "Board connection failed", t.getError());
                        call.reject("Connect failed: " + t.getError().getMessage());
                    } else {
                        Log.i(TAG, "Board connected successfully");
                        call.resolve();
                    }
                    return null;
                });
            }

            @Override public void onServiceDisconnected(ComponentName name) {
                Log.w(TAG, "BtleService disconnected");
            }
        }, Context.BIND_AUTO_CREATE);
    }

    public void startSensorFusion(PluginCall call) {
        if (board == null || !board.isConnected()) {
            call.reject("Board not connected");
            return;
        }

        fusion = board.getModule(SensorFusionBosch.class);
        if (fusion == null) {
            call.reject("SensorFusion module not available");
            return;
        }

        try {
            Log.i(TAG, "Configuring sensor fusion...");
            fusion.configure()
                    .mode(SensorFusionBosch.Mode.NDOF)
                    .accRange(SensorFusionBosch.AccRange.AR_16G)
                    .gyroRange(SensorFusionBosch.GyroRange.GR_2000DPS)
                    .commit();

            fusion.resetOrientation();

            fusion.correctedAcceleration().addRouteAsync(source -> source.stream((data, env) -> {
                SensorFusionBosch.CorrectedAcceleration acc = data.value(SensorFusionBosch.CorrectedAcceleration.class);
                Log.d(TAG, "ACC: " + acc);
                synchronized (dataMap) {
                    dataMap.put("acc", acc);
                    checkAndEmit(data.timestamp().getTimeInMillis());
                }
            })).continueWithTask(task -> {
                if (task.isFaulted()) throw task.getError();
                return fusion.correctedAngularVelocity().addRouteAsync(source -> source.stream((data, env) -> {
                    SensorFusionBosch.CorrectedAngularVelocity gyr = data.value(SensorFusionBosch.CorrectedAngularVelocity.class);
                    Log.d(TAG, "GYR: " + gyr);
                    synchronized (dataMap) {
                        dataMap.put("gyro", gyr);
                        checkAndEmit(data.timestamp().getTimeInMillis());
                    }
                }));
            }).continueWithTask(task -> {
                if (task.isFaulted()) throw task.getError();
                return fusion.correctedMagneticField().addRouteAsync(source -> source.stream((data, env) -> {
                    SensorFusionBosch.CorrectedMagneticField mag = data.value(SensorFusionBosch.CorrectedMagneticField.class);
                    Log.d(TAG, "MAG: " + mag);
                    synchronized (dataMap) {
                        dataMap.put("mag", mag);
                        checkAndEmit(data.timestamp().getTimeInMillis());
                    }
                }));
            }).continueWithTask(task -> {
                if (task.isFaulted()) throw task.getError();
                return fusion.quaternion().addRouteAsync(source -> source.stream((data, env) -> {
                    Quaternion quat = data.value(Quaternion.class);
                    Log.d(TAG, "QUAT: " + quat);
                    synchronized (dataMap) {
                        dataMap.put("quat", quat);
                        checkAndEmit(data.timestamp().getTimeInMillis());
                    }
                }));
            }).continueWith(task -> {
                if (task.isFaulted()) {
                    Log.e(TAG, "Sensor route setup failed", task.getError());
                    call.reject("Sensor route setup failed: " + task.getError().getMessage());
                } else {
                    Log.i(TAG, "All routes configured. Starting fusion streams...");

                    fusion.correctedAcceleration().start();
                    fusion.correctedAngularVelocity().start();
                    fusion.correctedMagneticField().start();
                    fusion.quaternion().start();
                    fusion.start();

                    Log.i(TAG, "SensorFusion started.");
                    call.resolve();
                }
                return null;
            });
        } catch (Exception e) {
            Log.e(TAG, "SensorFusion start error", e);
            call.reject("Error starting sensor fusion: " + e.getMessage());
        }
    }

    private void checkAndEmit(long ts) {
        if (dataMap.containsKey("acc") && dataMap.containsKey("gyro") &&
            dataMap.containsKey("mag") && dataMap.containsKey("quat")) {

            SensorFusionBosch.CorrectedAcceleration acc = (SensorFusionBosch.CorrectedAcceleration) dataMap.remove("acc");
            SensorFusionBosch.CorrectedAngularVelocity gyr = (SensorFusionBosch.CorrectedAngularVelocity) dataMap.remove("gyro");
            SensorFusionBosch.CorrectedMagneticField mag = (SensorFusionBosch.CorrectedMagneticField) dataMap.remove("mag");
            Quaternion quat = (Quaternion) dataMap.remove("quat");

            long count = counter.incrementAndGet();
            Date date = new Date(ts);

            if (useSensorDataClass) {
                SensorData sensorData = new SensorData(
                        ts, 0, 0, 0, 0,
                        acc.x(), acc.y(), acc.z(),
                        gyr.x(), gyr.y(), gyr.z(),
                        mag.x(), mag.y(), mag.z(),
                        quat.x(), quat.y(), quat.z(), quat.w(),
                        count, "NDOF", date
                );

                Log.i(TAG, "SensorData Object: " + sensorData);

                JSObject obj = new JSObject();
                obj.put("timestamp", sensorData.timeStamp);
                obj.put("counter", sensorData.counter);
                obj.put("xAccl", sensorData.xAccl);
                obj.put("yAccl", sensorData.yAccl);
                obj.put("zAccl", sensorData.zAccl);
                obj.put("xGyr", sensorData.xGyr);
                obj.put("yGyr", sensorData.yGyr);
                obj.put("zGyr", sensorData.zGyr);
                obj.put("xMag", sensorData.xMag);
                obj.put("yMag", sensorData.yMag);
                obj.put("zMag", sensorData.zMag);
                obj.put("xQuat", sensorData.xQuat);
                obj.put("yQuat", sensorData.yQuat);
                obj.put("zQuat", sensorData.zQuat);
                obj.put("wQuat", sensorData.wQuat);
                obj.put("date", sensorData.date.toString());

                plugin.sendSensorEvent("sensorData", obj);
            } else {
                JSObject obj = new JSObject();
                obj.put("timestamp", ts);
                obj.put("date", date.toString());
                obj.put("counter", count);

                obj.put("xAccl", acc.x());
                obj.put("yAccl", acc.y());
                obj.put("zAccl", acc.z());

                obj.put("xGyr", gyr.x());
                obj.put("yGyr", gyr.y());
                obj.put("zGyr", gyr.z());

                obj.put("xMag", mag.x());
                obj.put("yMag", mag.y());
                obj.put("zMag", mag.z());

                obj.put("xQuat", quat.x());
                obj.put("yQuat", quat.y());
                obj.put("zQuat", quat.z());
                obj.put("wQuat", quat.w());

                Log.i(TAG, "SensorData JSObject: " + obj.toString());
                plugin.sendSensorEvent("sensorData", obj);
            }
        }
    }

    public void stopSensorFusion(PluginCall call) {
        if (fusion != null) {
            fusion.stop();
            Log.i(TAG, "SensorFusion stopped");
        }
        call.resolve();
    }

    public void disconnect(PluginCall call) {
        Log.i(TAG, "Trying to disconnect from MetaWear board");
        if (board != null) {
            board.disconnectAsync().continueWith(task -> {
                Log.i(TAG, "Disconnected from MetaWear board");
                call.resolve();
                return null;
            });
        } else {
            call.reject("Board not connected");
        }
    }
}
