import 'package:flutter/material.dart';
import 'dashboard.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _title = _titles[0];

  static const List<String> _titles = ["PokeApi"];

  final List<Widget> _pages = [DashboardPage()];

  void _pageChange(int index) {
    setState(() {
      _selectedIndex = index;
      _title = _titles[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.catching_pokemon),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_title),
      ),
      body: _pages.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Buscar',
        child: const Icon(Icons.search),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop),
            label: 'Ubicaciones',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Equipos'),
        ],
      ),
    );
  }
}
