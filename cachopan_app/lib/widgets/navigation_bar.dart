import 'package:flutter/material.dart';
import '../utils.dart';
import '../pages/clients.dart';
import '../pages/articles.dart';
import '../pages/sales.dart';
import '../pages/invoices.dart';

class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

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

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      CustomPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: principal_color,
        height: 90,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
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
              _navigateToPage(context ,ClientsPage());
              break;
            case 1:
              _navigateToPage(context, ArticlesPage());
              break;
            case 2:
              _navigateToPage(context, SalesPage());
              break;
            case 3:
              _navigateToPage(context, InvoicesPage());
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