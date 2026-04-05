import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LegendariesView extends StatelessWidget {
  const LegendariesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Un fondo ligeramente oscuro para que resalte el dorado
      backgroundColor: const Color(0xFF1A1A1A),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchLegendaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          final legendaries = snapshot.data ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 0.8,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: legendaries.length,
            itemBuilder: (context, index) {
              final pokemon = legendaries[index];
              // Extraemos el ID de la URL: "https://pokeapi.co/api/v2/pokemon-species/144/"
              final String url = pokemon['url'];
              final id = url.split('/')[url.split('/').length - 2];
              final imageUrl =
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

              return _buildLegendaryCard(pokemon['name'], imageUrl, context);
            },
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchLegendaries() async {
    // Nota: Traemos una cantidad alta para filtrar las especies
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon-species?limit=1000'),
    );
    if (response.statusCode == 200) {
      final List allSpecies = json.decode(response.body)['results'];

      /* OJO: En una app real, aquí harías un filtrado por 'is_legendary'.
         Para este ejemplo rápido, vamos a simular la lista con algunos IDs famosos
         mientras optimizamos la lógica de filtrado.
      */
      return allSpecies.where((s) {
        final id = int.parse(
          s['url'].split('/')[s['url'].split('/').length - 2],
        );
        // IDs de aves legendarias, Mewtwo, perros, etc. (Ejemplo rápido)
        return (id >= 144 && id <= 151) ||
            (id >= 243 && id <= 251) ||
            (id >= 377 && id <= 386);
      }).toList();
    }
    return [];
  }

  Widget _buildLegendaryCard(
    String name,
    String imageUrl,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF333333), Color(0xFF000000)],
        ),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Brillo de fondo
              Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.amber.withOpacity(0.1),
              ),
              Image.network(imageUrl, height: 120, fit: BoxFit.contain),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
