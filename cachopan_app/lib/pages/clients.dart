import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/create_update_client_modal.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_are_you_sure.dart';
import '../widgets/error_modal.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/custom_search_field.dart';
import '../api.dart';
import 'dart:convert';
import '../models/client.dart';
import 'dart:async';

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<Client> clients = [];
  bool isLoading = true;
  String? _userId;
  String search = "";
  Timer? _debounce;

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
  }

  Future<void> _fetchClients() async {
    if (_userId != null) {
      final response = await ClientApi.getAllClients(int.parse(_userId!), search);
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
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        search = query.trim();
      });
      _fetchClients();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Clientes', icon: Icons.people),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomSearchBar(onSearch: _onSearch, hintText: 'Buscar cliente...'),
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
                      Text('Email: ${client.email ?? 'Sin email'}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
                      Text('Número: ${client.number ?? 'Sin número'}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateUpdateClientModal(client: client);
                                },
                              );
                            },
                            icon: Icon(Icons.update, size: 18),
                            label: Text('Actualizar', style: TextStyle(fontSize: 18)),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Custom AreYouSureModal
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AreYouSureModal(
                                    title: 'Eliminar cliente',
                                    content: '¿Estás seguro de que deseas eliminar a ${client.name}?',
                                    onConfirm: () async {
                                      final response = await ClientApi.deleteClient(client.id);
                                      if (response.statusCode == 204) {
                                        _fetchClients(); // Refresh the list of clients
                                      } else {
                                        // Error modal
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ErrorModal(
                                              title: 'Error',
                                              message: 'Error al eliminar el cliente',
                                            );
                                          },
                                        );
                                      }
                                    },
                                  );
                                },
                              );
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
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateUpdateClientModal();
            },
          );

          if (result == true) {
            _fetchClients(); // Refresh the list of clients
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}