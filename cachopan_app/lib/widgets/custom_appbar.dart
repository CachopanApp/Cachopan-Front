import 'package:cachopan_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  CustomAppBar({required this.title, this.height = 60});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final storage = FlutterSecureStorage();
    String? loadedUsername = await storage.read(key: 'username');
    setState(() {
      username = loadedUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: principal_color,
      title: Text(widget.title, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      automaticallyImplyLeading: false, // This removes the back arrow
      actions: <Widget>[
        if (username != null)
          Center(
            child: Text(username!, style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: PopupMenuButton<String>(
            tooltip: 'Menú', // Change tooltip text
            icon: Icon(Icons.person, size: 30, color: Colors.white),
            onSelected: (String result) {
              if (result == 'logout') {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}