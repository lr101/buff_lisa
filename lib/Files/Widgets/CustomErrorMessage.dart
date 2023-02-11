import 'package:flutter/material.dart';

class CustomErrorMessage{

  static void message({required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }
}