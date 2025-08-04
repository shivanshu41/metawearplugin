package com.wellmetrix.metawear;

import java.util.Date;

public class SensorData {
    public long timeStamp;
    public float xTemp, yTemp, zTemp, wTemp;
    public float xAccl, yAccl, zAccl;
    public float xGyr, yGyr, zGyr;
    public float xMag, yMag, zMag;
    public float xQuat, yQuat, zQuat, wQuat;
    public long counter;
    public String mode;
    public Date date;

    public SensorData(long timeStamp, float xTemp, float yTemp, float zTemp, float wTemp,
                      float xAccl, float yAccl, float zAccl,
                      float xGyr, float yGyr, float zGyr,
                      float xMag, float yMag, float zMag,
                      float xQuat, float yQuat, float zQuat, float wQuat,
                      long counter, String mode, Date date) {
        this.timeStamp = timeStamp;
        this.xTemp = xTemp;
        this.yTemp = yTemp;
        this.zTemp = zTemp;
        this.wTemp = wTemp;
        this.xAccl = xAccl;
        this.yAccl = yAccl;
        this.zAccl = zAccl;
        this.xGyr = xGyr;
        this.yGyr = yGyr;
        this.zGyr = zGyr;
        this.xMag = xMag;
        this.yMag = yMag;
        this.zMag = zMag;
        this.xQuat = xQuat;
        this.yQuat = yQuat;
        this.zQuat = zQuat;
        this.wQuat = wQuat;
        this.counter = counter;
        this.mode = mode;
        this.date = date;
    }

    @Override
    public String toString() {
        return "SensorData{" +
                "timeStamp=" + timeStamp +
                ", acc=[" + xAccl + "," + yAccl + "," + zAccl + "]" +
                ", gyro=[" + xGyr + "," + yGyr + "," + zGyr + "]" +
                ", mag=[" + xMag + "," + yMag + "," + zMag + "]" +
                ", quat=[" + wQuat + "," + xQuat + "," + yQuat + "," + zQuat + "]" +
                ", counter=" + counter +
                ", mode='" + mode + '\'' +
                ", date=" + date +
                '}';
    }
}
