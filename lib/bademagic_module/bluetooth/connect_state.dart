import 'package:badgemagic/bademagic_module/bluetooth/datagenerator.dart';
import 'package:badgemagic/bademagic_module/bluetooth/stream_state.dart';
import 'package:badgemagic/bademagic_module/bluetooth/write_state.dart';
import 'package:universal_ble/universal_ble.dart';
import 'base_ble_state.dart';

class ConnectState extends RetryBleState {
  final BleDevice scanResult;
  final DataTransferManager manager;
  final Stream<List<int>>? frameStream;

  ConnectState(
      {required this.manager, required this.scanResult, this.frameStream});

  @override
  Future<BleState?> processState() async {
    final deviceId = scanResult.deviceId;

    try {
      try {
        await UniversalBle.disconnect(deviceId);
        logger.d("Pre-emptive disconnect for clean state");
        await Future.delayed(const Duration(seconds: 1));
      } catch (_) {
        logger.d("No existing connection to disconnect");
      }

      await UniversalBle.connect(deviceId);

      final connectionState = await UniversalBle.getConnectionState(deviceId);

      if (connectionState == BleConnectionState.connected) {
        logger.d("Device connected successfully");
        toast.showToast('Device connected successfully.');

        manager.connectedDevice = scanResult;

        if (frameStream != null) {
          return await StreamState(
                  device: scanResult, frameStream: frameStream!)
              .process();
        } else {
          final writeState = WriteState(device: scanResult, manager: manager);
          return await writeState.process();
        }
      } else {
        throw Exception("Failed to connect to the device");
      }
    } catch (e) {
      toast.showErrorToast('Failed to connect. Retrying...');
      rethrow;
    }
  }
}
