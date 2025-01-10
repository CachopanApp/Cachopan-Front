import 'dart:convert';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cachopan_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../api.dart';
import '../models/sale.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/navigation_bar.dart';
import '../date_provider.dart';

class InvoicesPage extends StatefulWidget {
  @override
  _InvoicesPageState createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _dateFormatSearch = DateFormat('yyyy-MM-dd');

  String _selectedOrderType = 'Ordenar por Cliente Detallado';
  List<dynamic> invoices = [];
  Map<String, List<dynamic>> groupedInvoices = {};
  bool isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initKeyValues();
    await _fetchInvoices();
  }

  Future<void> _initKeyValues() async {
    final storage = FlutterSecureStorage();
    _userId = await storage.read(key: 'user_id');
  }

  Future<void> _fetchInvoices() async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    if (_userId != null) {
      final response = await SaleApi.getAllSalesFromUser(int.parse(_userId!), "", _dateFormatSearch.format(dateProvider.selectedDate));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            invoices = data.map((json) => Sale.fromJson(json)).toList();
            _groupInvoices();
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

  void _groupInvoices() {
    groupedInvoices.clear();
    if (_selectedOrderType == 'Ordenar por Cliente Detallado' || _selectedOrderType == 'Ordenar por Cliente Resumido') {
      for (Sale invoice in invoices) {
        String clientName = invoice.clientName;
        if (!groupedInvoices.containsKey(clientName)) {
          groupedInvoices[clientName] = [];
        }
        groupedInvoices[clientName]!.add(invoice);
      }
    } else if (_selectedOrderType == 'Ordenar por Artículo Detallado' || _selectedOrderType == 'Ordenar por Artículo Resumido') {
      for (Sale invoice in invoices) {
        String articleName = invoice.articleName;
        if (!groupedInvoices.containsKey(articleName)) {
          groupedInvoices[articleName] = [];
        }
        groupedInvoices[articleName]!.add(invoice);
      }
    }
  }

  double _calculateSubtotal(List<dynamic> invoices) {
    double subtotal = invoices.fold(0, (sum, invoice) => sum + invoice.total);
    return double.parse(subtotal.toStringAsFixed(2));
  }

  Future<void> _selectDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateProvider.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateProvider.selectedDate) {
      dateProvider.setDate(picked);
      setState(() {
        isLoading = true;
      });
      await _fetchInvoices();
    }
  }

  Future<void> _generatePdf(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    double total = groupedInvoices.values.fold(
        0, (sum, invoices) => sum + _calculateSubtotal(invoices));
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) => pw.Text(
          'Albarán del día ${_dateFormat.format(dateProvider.selectedDate)}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        footer: (pw.Context context) => pw.Text(
          'Total: ${total.toStringAsFixed(2)} euros',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        build: (pw.Context context) => [
          pw.Divider(),
          ...groupedInvoices.keys.map((key) {
            double subtotal = _calculateSubtotal(groupedInvoices[key]!);
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.all(8.0),
                  child: pw.Text(
                    '$key (Subtotal: ${subtotal.toStringAsFixed(2)} euros)',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                if (_selectedOrderType == 'Ordenar por Cliente Detallado' || _selectedOrderType == 'Ordenar por Artículo Detallado')
                  ...groupedInvoices[key]!.map((invoice) {
                    return pw.Text(
                      _selectedOrderType == 'Ordenar por Cliente Detallado'
                          ? '${invoice.articleName} : ${invoice.quantity} ${invoice.articleUnit} * ${invoice.priceUnit} euros = ${invoice.total} euros'
                          : '${invoice.clientName} : ${invoice.quantity} ${invoice.articleUnit} * ${invoice.priceUnit} euros = ${invoice.total} euros',
                      style: pw.TextStyle(fontSize: 13),
                    );
                  }).toList(),
                pw.SizedBox(height: 20),
              ],
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    double total = groupedInvoices.values
        .fold(0, (sum, invoices) => sum + _calculateSubtotal(invoices));

    return Scaffold(
      appBar: CustomAppBar(title: 'Albaranes', icon: Icons.receipt),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 700) {
                  return Column(
                    children: [
                      Row(
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
                      DropdownButton<String>(
                        value: _selectedOrderType,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedOrderType = newValue!;
                            _groupInvoices();
                          });
                        },
                        items: <String>[
                          'Ordenar por Cliente Detallado',
                          'Ordenar por Artículo Detallado',
                          'Ordenar por Cliente Resumido',
                          'Ordenar por Artículo Resumido'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                      DropdownButton<String>(
                        value: _selectedOrderType,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedOrderType = newValue!;
                            _groupInvoices();
                          });
                        },
                        items: <String>[
                          'Ordenar por Cliente Detallado',
                          'Ordenar por Artículo Detallado',
                          'Ordenar por Cliente Resumido',
                          'Ordenar por Artículo Resumido'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...groupedInvoices.keys.map((key) {
                    double subtotal = _calculateSubtotal(groupedInvoices[key]!);
                    return ExpansionTile(
                      initiallyExpanded: true,
                      title: Container(
                        color: Colors.grey[300],
                        padding: EdgeInsets.all(8.0),
                        child: Text('$key (Subtotal: ${subtotal.toStringAsFixed(2)} euros)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      children: _selectedOrderType == 'Ordenar por Cliente Detallado' || _selectedOrderType == 'Ordenar por Artículo Detallado'
                          ? groupedInvoices[key]!
                          .map<Widget>((invoice) => ListTile(
                        title: Text(
                            _selectedOrderType == 'Ordenar por Cliente Detallado'
                                ? '${invoice.articleName} : ${invoice.quantity} ${invoice.articleUnit} * ${invoice.priceUnit}€ = ${invoice.total}€'
                                : '${invoice.clientName} : ${invoice.quantity} ${invoice.articleUnit} * ${invoice.priceUnit}€ = ${invoice.total}€',
                            style: TextStyle(fontSize: 18)),
                      ))
                          .toList()
                          : [],
                    );
                  }).toList(),
                  ListTile(
                    title: Text(
                      'Total: ${total.toStringAsFixed(2)} euros',
                      style: TextStyle( fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generatePdf(context),
        icon: Icon(Icons.picture_as_pdf_rounded),
        label: Text("Pasar a PDF"),
        backgroundColor: Colors.grey,
      ),
      bottomNavigationBar: const CustomNavigationBar(initialIndex: 3),
    );
  }
}