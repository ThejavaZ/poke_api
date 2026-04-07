import 'package:flutter/material.dart';
import 'package:poke_api/elements/all.dart';
import 'package:poke_api/services/database_helper.dart';

class TeamDetailsPage extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamDetailsPage({super.key, required this.team});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editando: ${widget.team['name']}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            // En el IconButton del AppBar de TeamDetailsPage
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("¿Borrar equipo?"),
                  content: const Text("Esta acción no se puede deshacer."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("CANCELAR"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "BORRAR",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // Necesitaremos este método en DatabaseHelper
                await DatabaseHelper.deleteTeam(widget.team['id']);
                if (!mounted) return;
                Navigator.pop(context); // Regresa a la lista de equipos
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // Necesitaremos un método en DatabaseHelper para traer solo UN equipo
        future: DatabaseHelper.getTeamMembers(widget.team['id']),
        builder: (context, snapshot) {
          final members = snapshot.data ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: 6, // Los 6 slots de siempre
            itemBuilder: (context, index) {
              if (index < members.length) {
                return _buildMemberCard(members[index]);
              } else {
                return _buildAddMemberCard();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'pokemon-${member['id']}',
            child: Image.network(member['imageUrl'], height: 80),
          ),
          Text(
            member['pokemon_name'].toString().toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              // member['id'] es el ID de la tabla team_members
              await DatabaseHelper.removePokemonFromTeam(member['id']);
              setState(() {}); // Actualiza el Grid
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pokémon liberado del equipo")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberCard() {
    return GestureDetector(
      onTap: () {
        // Navegamos a la vista de todos los pokemons
        // Pasamos el teamId para saber que estamos en "modo selección"
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AllView(isSelectingForTeam: true),
          ),
        ).then((selectedPokemon) async {
          if (selectedPokemon != null) {
            // selectedPokemon vendría como un Map con name, url, id
            await DatabaseHelper.addPokemonToTeam(
              widget.team['id'],
              selectedPokemon['id'].toString(),
              selectedPokemon['name'],
              selectedPokemon['imageUrl'],
            );
            setState(() {}); // Refrescamos los 6 slots
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.add_circle_outline,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}
