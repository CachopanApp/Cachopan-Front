import 'package:flutter/material.dart';
import '../models/article.dart';
import '../api.dart';
import '../pages/articles.dart';
import 'custom_button.dart';
import 'error_modal.dart';
import 'custom_text_form_field.dart';

class CreateUpdateArticleModal extends StatefulWidget {
  final Article? article;
  final String formattedDate;

  CreateUpdateArticleModal({this.article, required this.formattedDate});

  @override
  _CreateUpdateArticleModalState createState() => _CreateUpdateArticleModalState();
}

class _CreateUpdateArticleModalState extends State<CreateUpdateArticleModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lotController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  String? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _lotController = TextEditingController(text: widget.article?.lot ?? '');
    if (widget.article?.lot == 'Pendiente') {
      _lotController = TextEditingController(text: '');
    }
    _nameController = TextEditingController(text: widget.article?.name ?? '');
    _priceController = TextEditingController(text: widget.article?.price.toString() ?? '');
    _selectedUnit = widget.article?.unit ?? 'Caja';
  }

  @override
  void dispose() {
    _lotController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {

      final articleData = {
        'name': _nameController.text,
        'lot': _lotController.text,
        'price': double.parse(_priceController.text),
        'unit': _selectedUnit,
      };

      try {
        if (widget.article == null) {
          // Create new article
          articleData['user_id'] = widget.article?.userId ?? 1;
          articleData['date'] = widget.formattedDate;
          final response = await ArticleApi.createArticle(articleData);
          if (response.statusCode != 201) {
            throw Exception('Error creating article');
          }
        } else {
          // Update existing article
          articleData['user_id'] = widget.article?.userId ?? 1;
          final response = await ArticleApi.updateArticle(widget.article!.id, articleData);
          if (response.statusCode != 200) {
            throw Exception('Error updating article');
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ArticlesPage()),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorModal(
              title: 'Error',
              message: e.toString(),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.article == null ? 'Crear Artículo' : 'Actualizar Artículo'),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.6, // Set the width of the modal
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  child: CustomTextFormField(
                    controller: _nameController,
                    labelText: 'Nombre',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el nombre';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  child: CustomTextFormField(
                    controller: _lotController,
                    labelText: 'Lote',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  child: CustomTextFormField(
                    controller: _priceController,
                    labelText: 'Precio',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el precio';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor ingrese un precio válido';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: InputDecoration(labelText: 'Unidad'),
                    items: ['Kg', 'Caja'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedUnit = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor seleccione una unidad';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CustomButton(
            text: widget.article == null ? 'Crear' : 'Actualizar',
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