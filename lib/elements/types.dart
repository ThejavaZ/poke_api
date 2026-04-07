import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TypesView extends StatelessWidget {
  const TypesView({super.key});

  // Mapeo de colores (mantenemos los mismos)
  static const Map<String, Color> typeColors = {
    'fire': Colors.orange,
    'water': Colors.blue,
    'grass': Colors.green,
    'electric': Color(0xFFFFD700),
    'ice': Colors.cyanAccent,
    'fighting': Colors.redAccent,
    'poison': Colors.purple,
    'ground': Colors.brown,
    'flying': Colors.indigoAccent,
    'psychic': Colors.pink,
    'bug': Colors.lightGreen,
    'rock': Colors.blueGrey,
    'ghost': Colors.deepPurple,
    'dragon': Colors.indigo,
    'dark': Colors.black54,
    'steel': Colors.grey,
    'fairy': Colors.pinkAccent,
    'normal': Colors.blueGrey,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchTypes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final types = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220, // Un poco más ancho para las imágenes
            childAspectRatio: 2.2, // Tarjetas un poco más altas
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: types.length,
          itemBuilder: (context, index) {
            final typeName = types[index]['name'];
            final color = typeColors[typeName] ?? Colors.grey;
            // Construimos la ruta de la imagen local dinámicamente
            final assetPath = 'images/types/$typeName.png';

            return ActionChip(
              elevation: 4,
              backgroundColor: color,
              // --- EL CAMBIO ESTÁ AQUÍ ---
              avatar: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(
                    assetPath,
                    // Si la imagen no carga (por ejemplo, si te faltó descargarla),
                    // mostramos un icono genérico para que no crashé
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.blur_on, size: 16),
                  ),
                ),
              ),
              // ---------------------------
              label: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  typeName.toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () =>
                  _showTypePokemon(context, types[index]['url'], typeName),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchTypes() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/type/'),
    );
    final List results = json.decode(response.body)['results'];
    // Filtramos los tipos 'unknown' y 'shadow'
    return results
        .where((t) => t['name'] != 'unknown' && t['name'] != 'shadow')
        .take(18)
        .toList();
  }

  // (Mantenemos la función _showTypePokemon igual que antes)
  void _showTypePokemon(BuildContext context, String url, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: FutureBuilder(
          future: http.get(Uri.parse(url)),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final data = json.decode(snapshot.data!.body);
            final List pokemonList = data['pokemon'];

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "POKÉMON TIPO ${title.toUpperCase()}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: typeColors[title],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: pokemonList.length,
                    itemBuilder: (context, i) {
                      final p = pokemonList[i]['pokemon'];
                      return ListTile(
                        leading: const Icon(
                          Icons.catching_pokemon,
                          color: Colors.red,
                        ),
                        title: Text(p['name'].toString().toUpperCase()),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navegar al DetailView pasándole el ID extraído de la URL
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
