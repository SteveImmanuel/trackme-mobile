import 'package:flutter/material.dart';

enum SnackBarType { success, failed, loading }

class SnackBarFactory {
  static SnackBar create({
    required int duration,
    required SnackBarType type,
    required String content,
  }) {
    Color color;
    Widget child = Text(content);
    switch (type) {
      case SnackBarType.success:
        color = Colors.green;
        break;
      case SnackBarType.failed:
        color = Colors.red;
        break;
      case SnackBarType.loading:
        color = Colors.grey;
        child = Row(
          children: [
            const SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black45,
              ),
              height: 20,
              width: 20,
            ),
            const SizedBox(
              width: 15,
            ),
            Text(content),
          ],
        );
        break;
    }

    return SnackBar(
      content: child,
      duration: Duration(milliseconds: duration),
      margin: const EdgeInsets.all(10),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
    );
  }
}
