export interface MetaWearPluginPlugin {
  connect(options: { deviceId: string }): Promise<{ success: boolean }>;
  startSensorFusion(): Promise<void>;
  stopSensorFusion(): Promise<void>;
  disconnect(): Promise<void>;
  addListener(
    eventName: 'sensorData',
    listenerFunc: (data: SensorData) => void
  ): Promise<void>;
  removeAllListeners(): Promise<void>;
}

export interface SensorData {
  timestamp: number;
  date: string;
  counter: number;
  xAccl: number;
  yAccl: number;
  zAccl: number;
  xGyr: number;
  yGyr: number;
  zGyr: number;
  xMag: number;
  yMag: number;
  zMag: number;
  xQuat: number;
  yQuat: number;
  zQuat: number;
  wQuat: number;
}
