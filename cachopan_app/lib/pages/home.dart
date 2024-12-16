import 'package:flutter/material.dart';
import 'dart:convert'; // Import the dart:convert library
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/custom_text_form_field.dart';
import '../widgets/custom_button.dart';
import '../api.dart'; // Import the UserApi class
import '../widgets/error_modal.dart'; // Import the UserApi class

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _contrasenaController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final response = await UserApi.getUser(
        _nombreController.text,
        _contrasenaController.text,
      );
      // Handle the response here (e.g., navigate to another screen or show an error message)
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String accessToken = responseData["access_token"];
        final String refreshToken = responseData["refresh_token"];
        final int user_id = responseData["user_id"];

        final storage = FlutterSecureStorage();

        await storage.write(key: 'access_token', value: accessToken);
        await storage.write(key: 'refresh_token', value: refreshToken);
        await storage.write(key: 'user_id', value: user_id.toString());
        await storage.write(key: 'username', value: _nombreController.text);

        Navigator.of(context).pushReplacementNamed('/clients');

      } else {

        // Error en el formulario
        showDialog(
          context: context,
          builder: (context) {
            return ErrorModal(
              title: 'Error',
              message: 'Credenciales erróneas o usuario incorrecto.',
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ocean.webp',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.all(38.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 50,
                    offset: Offset(10, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -80,
                          child: Container(
                            width: 105, // Tamaño reducido del contenedor
                            height: 105,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.95),
                            ),
                            child: OverflowBox(
                              maxWidth: 200, // Tamaño original de la imagen
                              maxHeight: 200,
                              child: Image.asset(
                                'assets/images/Cachopan_logo.webp',
                                width: 200,
                                height: 200,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: 80),
                            Text(
                              'Cachopan App',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 30),
                            CustomTextFormField(
                              controller: _nombreController,
                              labelText: 'Usuario',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese su usuario';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 30),
                            CustomTextFormField(
                              controller: _contrasenaController,
                              labelText: 'Contraseña',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese su contraseña';
                                }
                                return null;
                              },
                              obscureText: true,
                            ),
                            SizedBox(height: 20),
                            CustomButton(
                              text: 'Iniciar sesión',
                              onPressed: _login, // Call the _login method
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}