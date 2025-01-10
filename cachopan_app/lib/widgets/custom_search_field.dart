import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final String? hintText;

  CustomSearchBar({required this.onSearch, this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Container(// Use the provided width
        child: TextField(
          onChanged: onSearch,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 20), // Increase font size
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}