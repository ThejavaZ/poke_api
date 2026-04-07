import 'package:flutter/material.dart';
import 'home.dart';

class PokeApi extends StatelessWidget {
  const PokeApi({super.key});

  static const String _title = "PokeApi";

  final ThemeMode _mode = ThemeMode.system;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _mode,
      home: const MyHomePage(title: _title),
    );
  }
}
