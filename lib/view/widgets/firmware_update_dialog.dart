import 'package:flutter/material.dart';
import '../../services/firmware_update.dart';

class FirmwareUpdateDialog extends StatefulWidget {
  final String version;
  final String date;
  final FirmwareUpdateService service;

  const FirmwareUpdateDialog({
    super.key,
    required this.version,
    required this.date,
    required this.service,
  });

  @override
  State<FirmwareUpdateDialog> createState() => _FirmwareUpdateDialogState();
}

class _FirmwareUpdateDialogState extends State<FirmwareUpdateDialog> {
  bool _dontRemindAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.system_update, color: Colors.red),
          SizedBox(width: 10),
          Text('New Firmware Available'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A new firmware version is available for your badge.\n'),
          Text('• Version: ${widget.version}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('• Date: ${widget.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  activeColor: Colors.red,
                  value: _dontRemindAgain,
                  onChanged: (bool? value) {
                    setState(() {
                      _dontRemindAgain = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Don't remind me again for this version",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_dontRemindAgain) {
              await widget.service.skipVersionPermanently(widget.version);
            }
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Later'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            if (_dontRemindAgain) {
              await widget.service.skipVersionPermanently(widget.version);
            }
            if (context.mounted) Navigator.pop(context);
            // Calls the empty placeholder update method
            await widget.service.executeFirmwareUpdate(widget.version);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}