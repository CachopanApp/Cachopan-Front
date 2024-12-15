import 'package:flutter/material.dart';
import '../utils.dart';

class CustomNavigationBar extends StatefulWidget {
  final int initialIndex;

  const CustomNavigationBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late int currentPageIndex;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 90,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          return TextStyle(fontSize: 18); // Aumenta el tamaño de las etiquetas
        }),
      ),
      child: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/clients');
              break;
            case 1:
              Navigator.pushNamed(context, '/articles');
              break;
            case 2:
              Navigator.pushNamed(context, '/sales');
              break;
            case 3:
              Navigator.pushNamed(context, '/invoices');
              break;
          }
        },
        indicatorColor: principal_color,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.people, size: 30),
            icon: Icon(Icons.people_outline, size: 30),
            label: 'Clientes',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.inventory, size: 30),
            icon: Icon(Icons.inventory_2_outlined, size: 30),
            label: 'Artículos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.shopping_cart, size: 30),
            icon: Icon(Icons.shopping_cart_outlined, size: 30),
            label: 'Ventas',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.receipt, size: 30),
            icon: Icon(Icons.receipt_long_outlined, size: 30),
            label: 'Albaranes',
          ),
        ],
      ),
    );
  }
}