import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/auth.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: const Home(),
      theme: ThemeData(fontFamily: 'Roboto'),
    );
  }
}
