import 'package:flutter/material.dart';

import '../utils.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?) validator;
  final bool obscureText;

  CustomTextFormField({
    required this.controller,
    required this.labelText,
    required this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 20),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: principal_color),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: principal_color),
        ),
      ),
      validator: validator,
      style: TextStyle(fontSize: 20),
      obscureText: obscureText,
    );
  }
}