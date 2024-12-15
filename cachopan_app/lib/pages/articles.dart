import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';

class ArticlesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Contenido de Artículos',
          style: TextStyle(fontSize: 30),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(initialIndex: 1),
    );
  }
}