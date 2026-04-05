import 'package:flutter/material.dart';
import 'package:poke_api/services/database_helper.dart';
import 'package:poke_api/views/teams_details.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  // Función para refrescar la lista manualmente si es necesario
  void _refreshTeams() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.getTeamsWithMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final teams = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return _buildTeamCard(team);
            },
          );
        },
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    // Obtenemos la lista de pokemons del equipo (Join que hicimos en el helper)
    List pokemons = team['pokemons'] ?? [];
    String format = team['format'] ?? 'Individual';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // NAVEGACIÓN PRO
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailsPage(team: team),
            ),
          ).then((_) {
            // ESTA ES LA MAGIA: Cuando regresas de la página de detalle,
            // se ejecuta esto y refresca la lista de equipos.
            setState(() {});
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildFormatBadge(format), // Badge de formato
                    ],
                  ),
                  const Icon(Icons.edit_note, color: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 16),
              // Mini previsualización de los integrantes (Slots)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics:
                      const NeverScrollableScrollPhysics(), // Evita scroll interno
                  itemCount: 6,
                  itemBuilder: (context, i) {
                    if (i < pokemons.length) {
                      return _buildMiniSlot(pokemons[i]['imageUrl']);
                    } else {
                      return _buildEmptyMiniSlot();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${pokemons.length} / 6 Integrantes",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.circle, size: 10, color: _getFormatColor(format)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para la etiqueta de formato (VGC, Singles, etc)
  Widget _buildFormatBadge(String format) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getFormatColor(format).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _getFormatColor(format).withOpacity(0.5)),
      ),
      child: Text(
        format.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getFormatColor(format),
        ),
      ),
    );
  }

  Color _getFormatColor(String format) {
    switch (format.toLowerCase()) {
      case 'vgc':
        return Colors.amber.shade700;
      case 'individual':
        return Colors.blueAccent;
      default:
        return Colors.green;
    }
  }

  Widget _buildMiniSlot(String url) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 55,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildEmptyMiniSlot() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 55,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.add, color: Colors.grey.shade300, size: 20),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.catching_pokemon, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Tu campo de batalla está vacío",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Usa el menú para crear tu primer equipo",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
