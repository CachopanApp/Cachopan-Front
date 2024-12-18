import 'package:flutter/material.dart';
import '../models/article.dart';
import '../api.dart';
import '../pages/articles.dart';
import 'custom_button.dart';

class CreateUpdateArticleModal extends StatefulWidget {
  final Article? article;

  CreateUpdateArticleModal({this.article});

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
    _nameController = TextEditingController(text: widget.article?.name ?? '');
    _priceController = TextEditingController(text: widget.article?.price.toString() ?? '');
    _selectedUnit = widget.article?.unit ?? 'Kg';
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

      if (widget.article == null) {
        // Create new article
        articleData['user_id'] = widget.article?.userId?? 1;
        final response = await ArticleApi.createArticle(articleData);
        if (response.statusCode == 201) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ArticlesPage()));
        } else {
          // Handle error
          print('Error creating article');
        }
      } else {
        // Update existing article
        final response = await ArticleApi.updateArticle(widget.article!.id, articleData);
        if (response.statusCode == 200) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ArticlesPage()));
        } else {
          // Handle error
          print('Error updating article');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.article == null ? 'Crear Artículo' : 'Actualizar Artículo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: 300,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nombre'),
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
                width: 300,
                child: TextFormField(
                  controller: _lotController,
                  decoration: InputDecoration(labelText: 'Lote'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el lote';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: 300,
                child: TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
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
                width: 300,
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