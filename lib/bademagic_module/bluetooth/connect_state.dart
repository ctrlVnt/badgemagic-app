import 'package:badgemagic/bademagic_module/bluetooth/datagenerator.dart';
import 'package:badgemagic/bademagic_module/bluetooth/write_state.dart';
import 'package:get_it/get_it.dart';
import '../../view/widgets/ble_progress_dialog.dart';
import '../../view/widgets/ble_progress_dialog_controller.dart';
import 'package:universal_ble/universal_ble.dart';
import 'base_ble_state.dart';

class ConnectState extends RetryBleState {
  final BleDevice scanResult;
  final DataTransferManager manager;
  final bleDialogController = GetIt.instance<BleDialogController>();

  ConnectState({required this.manager, required this.scanResult});

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
        bleDialogController.update(
            BleDialogStatus.connecting, 'Device connected successfully.');

        manager.connectedDevice = scanResult;

        final writeState = WriteState(
          device: scanResult,
          manager: manager,
        );

        return await writeState.process();
      } else {
        throw Exception("Failed to connect to the device");
      }
    } catch (e) {
      bleDialogController.update(
          BleDialogStatus.error, 'Failed to connect. Retrying...');
      rethrow;
    }
  }
}
