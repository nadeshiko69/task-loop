import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, Object error) {
  final message = error is StateError ? error.message : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
