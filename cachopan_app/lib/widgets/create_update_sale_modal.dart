import 'dart:convert';

import 'package:cachopan_app/utils.dart';
import 'package:flutter/material.dart';
import '../pages/sales.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../api.dart';
import '../models/sale.dart';
import 'error_modal.dart';

class CreateUpdateSaleModal extends StatefulWidget {
  final Sale? sale;
  final String formattedDate;
  final String formattedDateSearch;
  final String userId;

  CreateUpdateSaleModal({this.sale, required this.formattedDate, required this.formattedDateSearch, required this.userId});

  @override
  _CreateUpdateSaleModalState createState() => _CreateUpdateSaleModalState();
}

class _CreateUpdateSaleModalState extends State<CreateUpdateSaleModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _articleNameController;
  late TextEditingController _clientNameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceUnitController;
  List<Map<String, String>> _articles = [];
  List<String> _clientNames = [];

  @override
  void initState() {
    super.initState();
    _articleNameController = TextEditingController(text: widget.sale?.articleName ?? '');
    _clientNameController = TextEditingController(text: widget.sale?.clientName ?? '');
    _quantityController = TextEditingController(text: widget.sale?.quantity.toString() ?? '');
    _priceUnitController = TextEditingController(text: widget.sale?.priceUnit.toString() ?? '');
    _fetchArticles();
    _fetchClients();
  }

  @override
  void dispose() {
    _articleNameController.dispose();
    _clientNameController.dispose();
    _quantityController.dispose();
    _priceUnitController.dispose();
    super.dispose();
  }

  Future<void> _fetchArticles() async {
    final response = await ArticleApi.getAllArticles(int.parse(widget.userId), "", widget.formattedDateSearch);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _articles = data.map((json) => {
          'name': json['name'].toString(),
          'lot': json['lot'].toString(),
          'price': json['price'].toString(),
        }).toList();
      });
    }
  }

  Future<void> _fetchClients() async {
    final response = await ClientApi.getAllClients(int.parse(widget.userId), "");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _clientNames = data.map((json) => json['name'].toString()).toList();
      });
    }
  }

  void _submit() async {
    if (_articleNameController.text.isEmpty || _clientNameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorModal(
            title: 'Error',
            message: 'Se necesita un nombre de artículo y cliente como mínimo para la venta.',
          );
        },
      );
      return;
    }

    if (!_articles.any((article) => article['name'] == _articleNameController.text)) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorModal(
            title: 'Error',
            message: 'El nombre del artículo no existe.',
          );
        },
      );
      return;
    }

    if (!_clientNames.contains(_clientNameController.text)) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorModal(
            title: 'Error',
            message: 'El nombre del cliente no existe.',
          );
        },
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      String error_desc = '';
      try {
        final double priceUnit = double.tryParse(_priceUnitController.text) ?? 0.0;

        final Map<String, dynamic> saleData = {
          'article_name': _articleNameController.text,
          'client_name': _clientNameController.text,
          'quantity': double.parse(_quantityController.text),
          'price_unit': priceUnit,
          'sale_date': widget.formattedDate,
          'user_id': widget.sale?.userId ?? widget.userId,
        };

        if (widget.sale == null) {
          // Create new sale
          final response = await SaleApi.createSale(saleData);
          if (response.statusCode != 201) {
            final errorData = json.decode(response.body);
            error_desc = errorData['description'];
            throw Exception('Fallo al registrar la venta: ${response.body}');
          }
        } else {
          // Quitar el user_id de la venta
          saleData.remove('user_id');
          // Update existing sale
          final response = await SaleApi.updateSale(widget.sale!.id, saleData);
          if (response.statusCode != 200) {
            final errorData = json.decode(response.body);
            error_desc = errorData['description'];
            throw Exception('Fallo al actualizar la venta: ${response.body}');
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SalesPage()),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorModal(
              title: 'Error',
              message: 'Error en el proceso de venta: ${error_desc}',
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.sale == null
          ? 'Crear Venta'
          : 'Actualizar Venta (${widget.sale!.articleName} - ${widget.sale!.clientName})'),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.sale == null) ...[
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _articles.map((article) => article['lot'] != '' ? '${article['name']} - Lote : ${article['lot']}' : '${article['name']} - Lote : Pendiente').where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _articleNameController.text = selection.split(' - ')[0];
                    });
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                    return CustomTextFormField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      labelText: 'Nombre del Artículo',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce el nombre del artículo';
                        }
                        return null;
                      },
                    );
                  },
                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 200,
                          child: ListView.builder(
                            padding: EdgeInsets.all(0.0),
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  String articleName = option.split(' - ')[0];
                                  String articlePrice = _articles.firstWhere((article) => article['name'] == articleName)['price']!;
                                  setState(() {
                                    _articleNameController.text = articleName;
                                    _priceUnitController.text = articlePrice;
                                  });
                                  onSelected(articleName);
                                },
                                child: ListTile(
                                  title: Text(option),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _clientNames.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _clientNameController.text = selection;
                    });
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                    return CustomTextFormField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      labelText: 'Nombre del Cliente',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce el nombre del cliente';
                        }
                        return null;
                      },
                    );
                  },
                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 200,
                          child: ListView.builder(
                            padding: EdgeInsets.all(0.0),
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _clientNameController.text = option;
                                  });
                                  onSelected(option);
                                },
                                child: ListTile(
                                  title: Text(option),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
              CustomTextFormField(
                controller: _quantityController,
                labelText: 'Cantidad',
                validator: (value) {
                  // Si no es entero o flotante
                  if (value == null || value.isEmpty || !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                    return 'Introduce una cantidad válida, los decimales con \'.\' (punto)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                controller: _priceUnitController,
                labelText: 'Precio Unitario',
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
                    return 'Introduce un precio unitario válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CustomButton(
            text: widget.sale == null ? 'Crear' : 'Actualizar',
            onPressed: _submit,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Center(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}