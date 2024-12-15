import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';

class InvoicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Contenido de Albaranes',
          style: TextStyle(fontSize: 30),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(initialIndex: 3),
    );
  }
}