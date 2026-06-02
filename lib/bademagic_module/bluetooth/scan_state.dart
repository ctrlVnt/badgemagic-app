import 'dart:async';
import 'package:badgemagic/bademagic_module/bluetooth/connect_state.dart';
import 'package:badgemagic/bademagic_module/bluetooth/datagenerator.dart';
import 'package:badgemagic/providers/BadgeScanProvider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_it/get_it.dart';
import '../../view/widgets/ble_progress_dialog.dart';
import '../../view/widgets/ble_progress_dialog_controller.dart';
import 'base_ble_state.dart';

class ScanState extends NormalBleState {
  final DataTransferManager manager;
  final BadgeScanMode mode;
  final List<String> allowedNames;
  final bleDialogController = GetIt.instance<BleDialogController>();

  ScanState({
    required this.manager,
    required this.mode,
    required this.allowedNames,
  });

  @override
  Future<BleState?> processState() async {
    manager.clearConnectedDevice();
    await FlutterBluePlus.stopScan();

    Completer<BleState?> nextStateCompleter = Completer();
    StreamSubscription<List<ScanResult>>? subscription;

    bool isCompleted = false;
    try {
      subscription = FlutterBluePlus.scanResults.listen(
        (results) async {
          if (isCompleted || results.isEmpty) return;

          try {
            final normalizedAllowedNames = allowedNames
                .map((e) => e.trim().toLowerCase())
                .where((e) => e.isNotEmpty)
                .toList();

            final foundDevice = results.firstWhere(
              (result) {
                final matchesUuid = result.advertisementData.serviceUuids
                    .contains(Guid("0000fee0-0000-1000-8000-00805f9b34fb"));

                final deviceName = result.device.name.trim().toLowerCase();
                final matchesName = mode == BadgeScanMode.any ||
                    normalizedAllowedNames.contains(deviceName);

                return matchesUuid && matchesName;
              },
              orElse: () => throw Exception("Matching device not found."),
            );

            isCompleted = true;
            FlutterBluePlus.stopScan();
            bleDialogController.update(BleDialogStatus.connecting, 'Device found. Connecting...');

            nextStateCompleter.complete(ConnectState(
              scanResult: foundDevice,
              manager: manager,
            ));
          } catch (e) {
            logger.w("No matching device found in this batch: $e");
          }
        },
        onError: (e) {
          if (!isCompleted) {
            isCompleted = true;
            FlutterBluePlus.stopScan();
            logger.e("Scan error: $e");
            bleDialogController.update(BleDialogStatus.error, 'Scan error occurred.');
            nextStateCompleter.completeError(
              Exception("Error during scanning: $e"),
            );
          }
        },
      );
      await FlutterBluePlus.startScan(
        withServices: [Guid("0000fee0-0000-1000-8000-00805f9b34fb")],
        removeIfGone: Duration(seconds: 5),
        continuousUpdates: true,
        timeout: const Duration(seconds: 15), // Reduced scan timeout.
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!isCompleted) {
        isCompleted = true;
        FlutterBluePlus.stopScan();
        bleDialogController.update(BleDialogStatus.error, 'Device not found.');
        nextStateCompleter.completeError(Exception('Device not found.'));
      }

      return await nextStateCompleter.future;
    } catch (e) {
      logger.e("Exception during scanning: $e");
      throw Exception("Please check if the device is turned on and retry.");
    } finally {
      await subscription?.cancel();
      await FlutterBluePlus.stopScan();
    }
  }
}
