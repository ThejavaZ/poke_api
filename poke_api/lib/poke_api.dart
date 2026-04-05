import 'package:flutter/material.dart';
import 'home.dart';

class PokeApi extends StatelessWidget {
  const PokeApi({super.key});

  static const String _title = "PokeApi";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.red),
        useMaterial3: false,
      ),
      home: const MyHomePage(title: _title),
    );
  }
}
