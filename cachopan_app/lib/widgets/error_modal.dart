import 'package:flutter/material.dart';

class ErrorModal extends StatelessWidget {
  final String title;
  final String message;

  ErrorModal({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 65),
      child: AlertDialog(
        title: Text(title, style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(fontSize: 24)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
}