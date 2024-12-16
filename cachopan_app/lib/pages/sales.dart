import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/navigation_bar.dart';

class SalesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Ventas'),
      body: Center(
        child: Text(
          'Contenido de Ventas',
          style: TextStyle(fontSize: 30),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(initialIndex: 2),
    );
  }
}