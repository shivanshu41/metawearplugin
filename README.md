# metawear

Metawear Sensor fusion plugin for modern ionic 5+

## Install

```bash
npm install metawear
npx cap sync
```

## API

<docgen-index>

* [`connect(...)`](#connect)
* [`startSensorFusion()`](#startsensorfusion)
* [`stopSensorFusion()`](#stopsensorfusion)
* [`disconnect()`](#disconnect)
* [`addListener('sensorData', ...)`](#addlistenersensordata-)
* [`removeAllListeners()`](#removealllisteners)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### connect(...)

```typescript
connect(options: { deviceId: string; }) => Promise<{ success: boolean; }>
```

| Param         | Type                               |
| ------------- | ---------------------------------- |
| **`options`** | <code>{ deviceId: string; }</code> |

**Returns:** <code>Promise&lt;{ success: boolean; }&gt;</code>

--------------------


### startSensorFusion()

```typescript
startSensorFusion() => Promise<void>
```

--------------------


### stopSensorFusion()

```typescript
stopSensorFusion() => Promise<void>
```

--------------------


### disconnect()

```typescript
disconnect() => Promise<void>
```

--------------------


### addListener('sensorData', ...)

```typescript
addListener(eventName: 'sensorData', listenerFunc: (data: { type: string; values: number[]; timestamp: number; }) => void) => Promise<void>
```

| Param              | Type                                                                                   |
| ------------------ | -------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'sensorData'</code>                                                              |
| **`listenerFunc`** | <code>(data: { type: string; values: number[]; timestamp: number; }) =&gt; void</code> |

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------

</docgen-api>
