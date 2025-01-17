import 'package:cachopan_app/utils.dart';
import 'package:flutter/material.dart';
import '../pages/clients.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../api.dart';
import '../models/client.dart';
import 'error_modal.dart';

class CreateUpdateClientModal extends StatefulWidget {
  final Client? client;

  CreateUpdateClientModal({this.client});

  @override
  _CreateUpdateClientModalState createState() => _CreateUpdateClientModalState();
}

class _CreateUpdateClientModalState extends State<CreateUpdateClientModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _numberController = TextEditingController(text: widget.client?.number ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorModal(
            title: 'Error',
            message: 'Se necesita un nombre como mínimo para el cliente.',
          );
        },
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> clientData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'number': _numberController.text,
      };

      try {
        if (widget.client == null) {
          // Create new client
          clientData['user_id'] = widget.client?.userId ?? 1; // Replace with actual user ID
          final response = await ClientApi.createClient(clientData);
          if (response.statusCode != 201) {
            throw Exception('Failed to create client');
          }
        } else {
          // Update existing client
          final response = await ClientApi.updateClient(widget.client!.id, clientData);
          if (response.statusCode != 200) {
            throw Exception('Failed to update client');
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ClientsPage()),
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
      title: Text(widget.client == null ? 'Crear Cliente' : 'Actualizar Cliente'),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.6, // Set the width of the modal
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nombre',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Add space between text fields
              CustomTextFormField(
                controller: _emailController,
                labelText: 'Email',
                validator: (value) {
                  if (value != null && value.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Introduce un email válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Add space between text fields
              CustomTextFormField(
                controller: _numberController,
                labelText: 'Número',
                validator: (value) {
                  if (value != null && value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Introduce un número válido';
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
            text: widget.client == null ? 'Crear' : 'Actualizar',
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