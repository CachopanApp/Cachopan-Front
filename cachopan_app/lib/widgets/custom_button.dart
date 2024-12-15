import 'package:flutter/material.dart';

import '../utils.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(fontSize: 25),
        minimumSize: Size(double.infinity, 60),
        elevation: 20,
        shadowColor: Colors.black,
        foregroundColor: Colors.white,
        backgroundColor: principal_color,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}