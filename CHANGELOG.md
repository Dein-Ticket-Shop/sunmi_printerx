## 1.4.0 (2026-08-03)

-   Add support for the Sunmi Cash Drawer Trigger (standalone USB/BLE dongle): `getCashDrawerTriggerUsb`, `scanCashDrawerTriggerBle`, `connectCashDrawerTriggerBle`, `getCashDrawerTriggerSerialNo`, `CashDrawerTrigger.open`/`isOpen`/`getSerialNo`
-   Work around unreliable native SDK callbacks confirmed against real hardware: BLE scan/connect no longer waits on `onFinish()` (bound to a fixed window instead), and opening the drawer confirms success via a status read instead of trusting the (never-invoked) completion callback

## 1.3.0 (2025-04-12)

-   Add methods for querying the printer status
-   Add methods for subscribing to printer events

## 1.2.1 (2025-04-12)

-   Fixed a bug where the alarm lamp would not always work

## 1.2.0 (2025-04-12)

-   Add `setAlarmLampColorStatic`, `setAlarmLampColorBlinking`, `setAlarmLampsOff` methods

## 1.1.0 (2024-08-02)

-   Add `setAlign`, `printText`, `addText`, `printTexts`, `printQrCode`, `autoOut` methods

## 1.0.0 (2024-07-27)

-   Initial implementation
