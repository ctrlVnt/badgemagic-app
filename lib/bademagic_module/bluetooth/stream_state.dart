import 'dart:async';
import 'dart:typed_data';
import 'package:badgemagic/globals/globals.dart';
import 'package:universal_ble/universal_ble.dart';
import 'base_ble_state.dart';
import 'completed_state.dart';

class StreamState extends NormalBleState {
  final BleDevice device;
  final Stream<List<int>> frameStream; // The UI will send 88-byte frames here

  // UUID of the new streaming service
  final String streamServiceUuid =
      "0000f055-0000-1000-8000-00805f9b34fb"; // Adapt if extended format
  final String writeCharUuid = "0000f057-0000-1000-8000-00805f9b34fb";
  final String notifyCharUuid = "0000f056-0000-1000-8000-00805f9b34fb";

  StreamState({required this.device, required this.frameStream});

  @override
  Future<BleState?> processState() async {
    final deviceId = device.deviceId;
    StreamSubscription? notifySubscription;
    StreamSubscription? frameSubscription;
    Completer<BleState?> streamLifecycleCompleter = Completer();

    // Local completer to synchronize ACK (the next frame starts only after notification)
    Completer<void>? ackCompleter;

    try {
      logger.d("Initializing Streaming mode...");
      await UniversalBle.discoverServices(deviceId);

      // 1. Subscribe to ACK Notifications (0xF056)
      await UniversalBle.subscribeNotifications(
          deviceId, streamServiceUuid, notifyCharUuid);

      // 2. Listen to the specific data stream for this notification characteristic
      notifySubscription =
          UniversalBle.characteristicValueStream(deviceId, notifyCharUuid)
              .listen(
        (Uint8List value) {
          // The badge has responded (1 byte). We unlock the sending of the next frame
          if (ackCompleter != null && !ackCompleter!.isCompleted) {
            logger.d("Application ACK received from the badge: $value");
            ackCompleter!.complete();
          }
        },
        onError: (error) {
          logger.e("Error in the GATT value stream: $error");
        },
      );

      // 2. Send Command: Enter streaming mode (02 00)
      await UniversalBle.write(deviceId, streamServiceUuid, writeCharUuid,
          Uint8List.fromList([0x02, 0x00]),
          withoutResponse: false);
      toast.showToast("Streaming Mode Active");

      // 3. Listen to frames from the UI/Provider
      frameSubscription = frameStream.listen((rawFrame) async {
        if (rawFrame.length != 88) return;

        // Security check before writing: if the app has disconnected, do not attempt to send
        final connectionState = await UniversalBle.getConnectionState(deviceId);
        if (connectionState != BleConnectionState.connected) {
          logger.w(
              "Device no longer connected. Stopping listening to frames.");
          if (!streamLifecycleCompleter.isCompleted) {
            streamLifecycleCompleter.complete(null);
          }
          return;
        }

        final packet = Uint8List(89);
        packet[0] = 0x03;
        packet.setRange(1, 89, rawFrame);

        ackCompleter = Completer<void>();

        try {
          await UniversalBle.write(
              deviceId, streamServiceUuid, writeCharUuid, packet,
              withoutResponse: false);

          // We relax the timeout to 250ms to give Android some margin
          await ackCompleter!.future.timeout(const Duration(milliseconds: 250),
              onTimeout: () {
            logger.w("Application ACK skipped for this frame, continuing...");
          });
        } catch (e) {
          logger.e("Error sending frame (GATT disconnected): $e");
          // If the write fails because the device has disappeared, we exit the state
          if (!streamLifecycleCompleter.isCompleted) {
            streamLifecycleCompleter.complete(null);
          }
        }
      }, onDone: () {
        if (!streamLifecycleCompleter.isCompleted) {
          streamLifecycleCompleter.complete(null);
        }
      });

      // Keeps the state active as long as the UI sends data
      await streamLifecycleCompleter.future;

      // 4. Send Command: Exit streaming mode (02 01)
      logger.d("Closing Streaming mode...");
      await UniversalBle.write(deviceId, streamServiceUuid, writeCharUuid,
          Uint8List.fromList([0x02, 0x01]),
          withoutResponse: false);

      return CompletedState(
          isSuccess: true, message: "Streaming finished successfully");
    } catch (e) {
      logger.e("Error during streaming: $e");
      return CompletedState(
          isSuccess: false, message: "Streaming error: $e");
    } finally {
      await frameSubscription?.cancel();
      await notifySubscription?.cancel();

      try {
        // Communicates to the badge's hardware to deactivate the notification channels
        await UniversalBle.unsubscribe(
            deviceId, streamServiceUuid, notifyCharUuid);
      } catch (e) {
        logger.w(
            "Error during unsubscribe (probably already disconnected): $e");
      }

      try {
        // Closes the GATT connection cleanly
        await UniversalBle.disconnect(deviceId);
      } catch (_) {}
      try {
        await UniversalBle.setNotifiable(deviceId, streamServiceUuid,
            notifyCharUuid, BleInputProperty.disabled);
      } catch (_) {}
      await notifySubscription?.cancel();
      try {
        await UniversalBle.disconnect(deviceId);
      } catch (_) {}
    }
  }
}
