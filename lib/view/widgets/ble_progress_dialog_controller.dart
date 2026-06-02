import 'package:flutter/cupertino.dart';

import 'ble_progress_dialog.dart';

class BleDialogController {
  final ValueNotifier<BleDialogStatus> status =
      ValueNotifier(BleDialogStatus.searching);
  final ValueNotifier<double> progress = ValueNotifier(0.0);
  final ValueNotifier<String> message = ValueNotifier("Searching...");

  void update(BleDialogStatus newStatus, String newMessage,
      {double newProgress = 0.0}) {
    status.value = newStatus;
    message.value = newMessage;
    progress.value = newProgress;
  }
}
