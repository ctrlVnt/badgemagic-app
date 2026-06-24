import 'package:badgemagic/bademagic_module/bluetooth/completed_state.dart';
import 'package:badgemagic/bademagic_module/utils/toast_utils.dart';
import 'package:logger/logger.dart';

abstract class BleState {
  Future<BleState?> process();
}

abstract class NormalBleState extends BleState {
  final logger = Logger();
  final toast = ToastUtils();

  Future<BleState?> processState();

  @override
  Future<BleState?> process() async {
    try {
      return await processState();
    } on Exception catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      return CompletedState(isSuccess: false, message: errorMessage);
    }
  }
}

abstract class RetryBleState extends BleState {
  final logger = Logger();
  final toast = ToastUtils();

  final _maxRetries = 3;

  Future<BleState?> processState();

  @override
  Future<BleState?> process() async {
    int attempt = 0;
    String lastErrorMessage = "Unknown error";

    while (attempt < _maxRetries) {
      try {
        return await processState();
      } on Exception catch (e) {
        // Immediately cleans the message from the "Exception: " infix
        lastErrorMessage = e.toString().replaceFirst('Exception: ', '');
        logger.e(
            "Error caught on attempt ${attempt + 1}: $lastErrorMessage");

        attempt++;
        if (attempt < _maxRetries) {
          logger.d(
              "GATT clogged. Waiting for decongestion before attempt $attempt/$_maxRetries...");

          // CRITICAL: 1.5 second pause allows Android to clear the command queue
          await Future.delayed(const Duration(milliseconds: 1500));
        } else {
          logger.e("Maximum number of attempts reached.");
          lastErrorMessage =
              "Connection failed after $_maxRetries attempts ($lastErrorMessage).";
        }
      }
    }

    // After exceeding retries, returns a clean failure without crashing the app
    return CompletedState(isSuccess: false, message: lastErrorMessage);
  }
}
