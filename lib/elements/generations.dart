import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'all.dart'; // Para reusar el DetailView

class GenerationsView extends StatelessWidget {
  const GenerationsView({super.key});

  // Mapa de colores para las regiones (Kanto es rojo, Johto oro/plata, etc.)
  static const Map<String, Color> genColors = {
    'generation-i': Colors.red,
    'generation-ii': Colors.blueGrey,
    'generation-iii': Colors.green,
    'generation-iv': Colors.blue,
    'generation-v': Colors.black87,
    'generation-vi': Colors.pink,
    'generation-vii': Colors.orange,
    'generation-viii': Colors.cyan,
    'generation-ix': Colors.deepPurple,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchGens(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final gens = snapshot.data ?? [];

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300, // Se adapta a escritorio/tablet/móvil
            childAspectRatio: 1.5,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: gens.length,
          itemBuilder: (context, index) {
            final genName = gens[index]['name'];
            final color = genColors[genName] ?? Colors.grey;

            return InkWell(
              onTap: () {
                // Aquí podrías abrir una lista filtrada o un modal
                _showGenPokemon(context, gens[index]['url'], genName);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.4), blurRadius: 5),
                  ],
                ),
                child: Center(
                  child: Text(
                    genName.toString().toUpperCase().replaceAll('-', ' '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchGens() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/generation/'),
    );
    return json.decode(response.body)['results'];
  }

  // Mini-función para mostrar los Pokémon de esa gen
  void _showGenPokemon(BuildContext context, String url, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => FutureBuilder(
          future: http.get(Uri.parse(url)),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final data = json.decode(snapshot.data!.body);
            final List pokemonList = data['pokemon_species'];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: pokemonList.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        title: Text(
                          pokemonList[i]['name'].toString().toUpperCase(),
                        ),
                        leading: const Icon(Icons.catching_pokemon),
                        onTap: () {
                          // Aquí podrías navegar al PokemonDetailView que ya hicimos
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
