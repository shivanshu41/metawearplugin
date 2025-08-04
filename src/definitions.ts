export interface MetaWearPluginPlugin {
  connect(options: { deviceId: string }): Promise<{ success: boolean }>;
  startSensorFusion(): Promise<void>;
  stopSensorFusion(): Promise<void>;
  disconnect(): Promise<void>;
  addListener(
    eventName: 'sensorData',
    listenerFunc: (data: { type: string; values: number[]; timestamp: number }) => void
  ): Promise<void>;
  removeAllListeners(): Promise<void>;
}
