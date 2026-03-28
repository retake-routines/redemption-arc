import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// An adaptive switch that renders [CupertinoSwitch] on iOS and macOS,
/// and [Switch] on all other platforms.
class AdaptiveSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const AdaptiveSwitch({
    required this.value,
    super.key,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor:
            activeColor ?? Theme.of(context).colorScheme.primary,
      );
    }

    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeColor,
    );
  }
}

/// Shows an adaptive dialog: [CupertinoAlertDialog] on iOS/macOS,
/// [AlertDialog] on other platforms.
///
/// Returns the value from the dialog (typically a `bool` for confirm/cancel).
Future<T?> showAdaptiveConfirmDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) {
  final platform = Theme.of(context).platform;
  final isCupertino =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  if (isCupertino) {
    return showCupertinoDialog<T>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
