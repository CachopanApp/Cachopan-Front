import 'package:flutter/material.dart';

class AreYouSureModal extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  AreYouSureModal({
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancelar', style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          child: Text('Confirmar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }
}