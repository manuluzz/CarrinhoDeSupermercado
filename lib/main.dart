// main.dart
import 'package:flutter/material.dart';
import 'package:carrinhodesupermercado/login_screen.dart';

void main() {
  runApp(SupermarketApp());
}

class SupermarketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
