import 'package:flutter/material.dart';
import 'package:poke_api/elements/favorites.dart';
import 'package:poke_api/elements/generations.dart';
import 'package:poke_api/elements/legendaries.dart';
import 'package:poke_api/elements/types.dart';
import 'package:poke_api/services/database_helper.dart';
import 'views/dashboard.dart';
import 'views/locations.dart';
import 'views/teams.dart';
import 'elements/all.dart';
import 'views/profile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    "Inicio",
    "Ubicaciones",
    "Equipos",
    "Todos los Pokémons",
    "Por generaciones",
    "Por tipos",
    "Legendarios",
    "Favoritos",
  ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      DashboardPage(onSubPageChange: _pageChange),
      const LocationsPage(),
      const TeamsPage(),
      const AllView(),
      const GenerationsView(),
      const TypesView(),
      const LegendariesView(),
      const FavoritesView(),
    ];
  }

  void _pageChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- LÓGICA DE CREACIÓN DE EQUIPO ---
  void _showCreateTeamDialog() {
    final TextEditingController _nameController = TextEditingController();
    String _selectedFormat = 'Individual';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("NUEVO EQUIPO"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre del equipo",
                hintText: "Ej: Equipo de Paola 🌿",
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedFormat,
              items: [
                'Individual',
                'VGC',
                'Temático',
              ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) => _selectedFormat = val!,
              decoration: const InputDecoration(labelText: "Formato de duelo"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                await DatabaseHelper.createTeam(
                  _nameController.text,
                  _selectedFormat,
                );
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {}); // Refresca el FutureBuilder de la TeamsPage
              }
            },
            child: const Text("CREAR"),
          ),
        ],
      ),
    );
  }

  // --- MENÚ DEL FAB ---
  void _showActionMenu(BuildContext context) {
    String contextAction = "Acción rápida";
    IconData contextIcon = Icons.flash_on;
    VoidCallback? onContextTap;

    if (_selectedIndex == 2) {
      contextAction = "Nuevo Equipo";
      contextIcon = Icons.add_box;
      onContextTap = () => _showCreateTeamDialog();
    } else if (_selectedIndex == 7) {
      contextAction = "Limpiar favoritos";
      contextIcon = Icons.delete_sweep;
      onContextTap = () => print("Limpiar favoritos logic");
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(contextIcon, color: Colors.purple),
                title: Text(
                  contextAction,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (onContextTap != null) onContextTap();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.casino, color: Colors.orange),
                title: const Text("Pokémon Aleatorio"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.wifi_tethering, color: Colors.green),
                title: const Text("Multijugador (P2P)"),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _selectedIndex > 2
            ? IconButton(
                onPressed: () => _pageChange(0),
                icon: const Icon(Icons.arrow_back),
              )
            : const Icon(Icons.catching_pokemon),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(_titles[_selectedIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
                setState(() {});
              },
              child: FutureBuilder<Map<String, dynamic>?>(
                future: DatabaseHelper.getProfile(),
                builder: (context, snapshot) {
                  String avatarPath = "images/trainers/red.png";
                  if (snapshot.hasData && snapshot.data != null) {
                    avatarPath = snapshot.data!['avatarPath'];
                  }
                  return Hero(
                    tag: 'profile-avatar',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(avatarPath),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionMenu(context),
        tooltip: 'Acciones de Entrenador',
        child: const Icon(Icons.add_reaction_outlined),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 2 ? 0 : _selectedIndex,
        onTap: (index) => _pageChange(index),
        items: const [
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
