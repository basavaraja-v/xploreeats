import 'package:flutter/material.dart';
import 'package:xploreeats/utils/app_constants.dart';

class CustomCheckboxListTile extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool?) onChanged;

  const CustomCheckboxListTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title, style: AppConstants.labelTextStyle),
      value: value,
      onChanged: onChanged,
      activeColor: AppConstants.primaryColor,
    );
  }
}
