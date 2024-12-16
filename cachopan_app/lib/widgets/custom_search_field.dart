import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;

  CustomSearchBar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Buscar...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}