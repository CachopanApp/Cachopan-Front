import 'package:cachopan_app/utils.dart';
import 'package:flutter/material.dart';
import '../pages/clients.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import '../api.dart';
import '../models/client.dart';

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
          return AlertDialog(
            title: Text('Error', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25)),
            content: Text('Se necesita un nombre como mínimo para el cliente.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar',  style: TextStyle(color: principal_color, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final Map<String,dynamic> clientData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'number': _numberController.text,
      };

      if (widget.client == null) {
        // Create new client
        clientData['user_id'] = widget.client?.userId ?? 1; // Replace with actual user ID
        await ClientApi.createClient(clientData);
      } else {
        // Update existing client
        print (clientData.toString());
        await ClientApi.updateClient(widget.client!.id, clientData);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClientsPage()),
      );
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