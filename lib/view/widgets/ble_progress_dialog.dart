import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum BleDialogStatus { searching, connecting, transferring, success, error }

class BleProgressDialog extends StatelessWidget {
  final BleDialogStatus status;
  final double progress;
  final String message;

  const BleProgressDialog({
    super.key,
    required this.status,
    required this.progress,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFinished = status == BleDialogStatus.success || status == BleDialogStatus.error;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(16.dg),
      content: SizedBox(
        width: 150.w,
        height: 160.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconOrAnimation(),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (status == BleDialogStatus.transferring) ...[
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blue,
                  minHeight: 6.h,
                ),
              ),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: isFinished
          ? [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: status == BleDialogStatus.success ? Colors.blue : Colors.red,
            textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ]
          : null,
    );
  }

  Widget _buildIconOrAnimation() {
    switch (status) {
      case BleDialogStatus.searching:
        return const _TweakedPulseAnimation(
          child: Icon(Icons.bluetooth_searching, size: 44, color: Colors.red),
        );
      case BleDialogStatus.connecting:
        return const Icon(Icons.bluetooth_connected, size: 44, color: Colors.amber);
      case BleDialogStatus.transferring:
        return const Icon(Icons.swap_vertical_circle_outlined, size: 44, color: Colors.blue);
      case BleDialogStatus.success:
        return const Icon(Icons.check_circle_rounded, size: 44, color: Colors.green);
      case BleDialogStatus.error:
        return const Icon(Icons.error_outline_rounded, size: 44, color: Colors.red);
    }
  }
}

class _TweakedPulseAnimation extends StatefulWidget {
  final Widget child;
  const _TweakedPulseAnimation({required this.child});

  @override
  State<_TweakedPulseAnimation> createState() => _TweakedPulseAnimationState();
}

class _TweakedPulseAnimationState extends State<_TweakedPulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}