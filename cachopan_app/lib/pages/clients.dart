import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/custom_search_field.dart';
import '../api.dart';
import 'dart:convert';

class Client {
  final int id;
  final String name;
  final String? email;
  final String? number;
  final int userId;

  Client({
    required this.id,
    required this.name,
    this.email,
    this.number,
    required this.userId,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      number: json['number'],
      userId: json['user_id'],
    );
  }
}

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<Client> clients = [];
  bool isLoading = true;
  String? _userId;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initKeyValues();
    await _fetchClients();
  }

  Future<void> _initKeyValues() async {
    final storage = FlutterSecureStorage();
    _userId = await storage.read(key: 'user_id');
    _accessToken = await storage.read(key: 'access_token');
  }

  Future<void> _fetchClients() async {
    if (_userId != null && _accessToken != null) {
      final response = await ClientApi.getAllClients(int.parse(_userId!), _accessToken!);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          clients = data.map((json) => Client.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    // Implement search functionality here
    print('Search query: $query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Clientes'),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomSearchBar(onSearch: _onSearch),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 80, top:10), // Add padding to the bottom
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Email: ${client.email ?? 'N/A'}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
                      Text('Número: ${client.number ?? 'N/A'}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // Add update functionality here
                            },
                            icon: Icon(Icons.update, size: 18),
                            label: Text('Actualizar', style: TextStyle(fontSize: 18)),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Add delete functionality here
                            },
                            icon: Icon(Icons.delete, size: 18, color: Colors.red),
                            label: Text('Eliminar', style: TextStyle(fontSize: 18, color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(initialIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality here
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}