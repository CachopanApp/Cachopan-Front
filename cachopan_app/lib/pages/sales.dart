import 'package:cachopan_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/create_update_sale_modal.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_are_you_sure.dart';
import '../widgets/custom_search_field.dart';
import '../widgets/error_modal.dart';
import '../widgets/navigation_bar.dart';
import '../api.dart';
import 'dart:convert';
import '../models/sale.dart';
import '../date_provider.dart'; // Import the DateProvider class
import 'dart:async';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _dateFormatSearch = DateFormat('yyyy-MM-dd');

  List<Sale> sales = [];
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
    await _fetchSales();
  }

  Future<void> _initKeyValues() async {
    final storage = FlutterSecureStorage();
    _userId = await storage.read(key: 'user_id');
  }

  Future<void> _fetchSales() async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    if (_userId != null) {
      final response = await SaleApi.getAllSalesFromUser(int.parse(_userId!), search, _dateFormatSearch.format(dateProvider.selectedDate));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            sales = data.map((json) => Sale.fromJson(json)).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        search = query.trim();
      });
      _fetchSales();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: dateProvider.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateProvider.selectedDate) {
      dateProvider.setDate(picked);
      _fetchSales();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Ventas', icon: Icons.shopping_cart),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    label: Text('Seleccionar Fecha', style: TextStyle(fontSize: 20, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 5,
                      shadowColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(150, 60),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: principal_color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _dateFormat.format(dateProvider.selectedDate),
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomSearchBar(onSearch: _onSearch, hintText: 'Buscar por cliente ...'),
          ),
          Expanded(
            child: sales.isEmpty
                ? Center(child: Text('No hay ventas insertadas', style: TextStyle(fontSize: 18)))
                : ListView.builder(
              padding: EdgeInsets.only(bottom: 80, top: 10),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
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
                      Text('Artículo: ${sale.articleName}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Cliente: ${sale.clientName}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Cantidad: ${sale.quantity}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20)),
                      Text('Precio Unitario (${sale.articleUnit}): ${sale.priceUnit}€', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20)),
                      Text('Total: ${sale.total}€', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateUpdateSaleModal(sale: sale, formattedDate: _dateFormat.format(dateProvider.selectedDate), formattedDateSearch: _dateFormatSearch.format(dateProvider.selectedDate), userId: _userId!);
                                },
                              );
                            },
                            icon: Icon(Icons.update, size: 18),
                            label: Text('Actualizar', style: TextStyle(fontSize: 18)),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AreYouSureModal(
                                    title: 'Eliminar venta',
                                    content: '¿Estás seguro de que deseas eliminar la venta de ${sale.articleName}?',
                                    onConfirm: () async {
                                      final response = await SaleApi.deleteSale(sale.id);
                                      if (response.statusCode == 204) {
                                        _fetchSales();
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ErrorModal(
                                              title: 'Error',
                                              message: 'Error al eliminar la venta',
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
      bottomNavigationBar: const CustomNavigationBar(initialIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateUpdateSaleModal(formattedDate: _dateFormat.format(dateProvider.selectedDate), formattedDateSearch: _dateFormatSearch.format(dateProvider.selectedDate), userId: _userId!);
            },
          );

          if (result == true) {
            _fetchSales();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}