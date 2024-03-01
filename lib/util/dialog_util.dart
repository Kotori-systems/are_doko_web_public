import 'package:flutter/material.dart';

class DialogUtil {
  static Future<void> showErrorDialog(
    BuildContext context,
    String content,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showWarningDialog(
    BuildContext context,
    String content,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showConfirmationDialog(
    BuildContext context,
    String content,
    VoidCallback onPressedOk,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onPressedOk();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
