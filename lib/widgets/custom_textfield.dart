import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
