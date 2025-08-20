import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MessageUtils {
  /// Show a toast message with fallback to SnackBar if toast fails
  static void showMessage(
    BuildContext context, 
    String message, {
    Color? backgroundColor,
    Toast? toastLength,
  }) {
    try {
      // Try to use fluttertoast
      Fluttertoast.showToast(
        msg: message,
        toastLength: toastLength ?? Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: backgroundColor ?? Colors.black87,
        textColor: Colors.white,
      );
    } catch (e) {
      // Fallback to SnackBar if toast fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: Duration(
            seconds: toastLength == Toast.LENGTH_LONG ? 3 : 2,
          ),
        ),
      );
    }
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    showMessage(
      context, 
      message, 
      backgroundColor: Colors.green,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  /// Show error message
  static void showError(BuildContext context, String message) {
    showMessage(
      context, 
      message, 
      backgroundColor: Colors.red,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    showMessage(
      context, 
      message, 
      backgroundColor: Colors.blue,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    showMessage(
      context, 
      message, 
      backgroundColor: Colors.orange,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
