import 'package:flutter/material.dart';
import 'package:poke_api/services/database_helper.dart'; // Importa tu helper

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedAvatar = "images/trainers/red.png";

  @override
  void initState() {
    super.initState();
    _loadProfile(); // Cargamos los datos al iniciar
  }

  // Método para leer de SQLite
  Future<void> _loadProfile() async {
    final profile = await DatabaseHelper.getProfile();
    if (profile != null) {
      setState(() {
        _nameController.text = profile['name'];
        _selectedAvatar = profile['avatarPath'];
      });
    } else {
      _nameController.text = "Entrenador"; // Valor por defecto
    }
  }

  // Método para guardar en SQLite
  Future<void> _saveProfile() async {
    await DatabaseHelper.saveProfile(_nameController.text, _selectedAvatar);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("¡Perfil guardado en la Pokedex!")),
    );
    // Opcional: Volver atrás automáticamente
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MI PERFIL POKÉMON"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Hero(
              tag: 'profile-avatar',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: AssetImage(_selectedAvatar),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre de Entrenador",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Elige tu clase:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                children: [
                  _avatarOption("images/trainers/red.png"),
                  _avatarOption("images/trainers/blue.png"),
                  _avatarOption("images/trainers/leaf.png"),
                  _avatarOption("images/trainers/ethan.png"),
                  _avatarOption("images/trainers/silver.png"),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text("GUARDAR CAMBIOS"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarOption(String path) {
    return GestureDetector(
      onTap: () => setState(() => _selectedAvatar = path),
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedAvatar == path ? Colors.blue : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
