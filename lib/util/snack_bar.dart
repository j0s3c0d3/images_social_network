import 'package:flutter/material.dart';

class ShowSnackBar {

  static void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 3),
      showCloseIcon: true,
    ));
  }
}