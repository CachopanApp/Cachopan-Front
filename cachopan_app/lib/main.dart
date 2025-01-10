import 'package:cachopan_app/pages/articles.dart';
import 'package:cachopan_app/pages/clients.dart';
import 'package:cachopan_app/pages/home.dart';
import 'package:cachopan_app/pages/invoices.dart';
import 'package:cachopan_app/pages/sales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'utils.dart';
import 'package:cachopan_app/date_provider.dart'; // Import the DateProvider class

//keke
//@Keke1234

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DateProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cachopan App',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: principal_color,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: principal_color,
          secondary: principal_color,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: principal_color,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: principal_color),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: principal_color),
          ),
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false, // Oculta el banner de debug
      routes: {
        '/home': (context) => HomeScreen(),
        '/clients': (context) =>  ClientsPage(),
        '/sales': (context) =>  SalesPage(),
        '/articles': (context) =>  ArticlesPage(),
        '/invoices': (context) =>  InvoicesPage(),
      },

        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('es', 'ES'),
        ],
    );
  }
}