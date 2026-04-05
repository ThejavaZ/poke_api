import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poke_api/services/database_helper.dart';

class PokemonDetailView extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String id;

  const PokemonDetailView({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.id,
  });

  @override
  State<PokemonDetailView> createState() => _PokemonDetailViewState();
}

class _PokemonDetailViewState extends State<PokemonDetailView> {
  bool isFavorite = false;
  Map<String, dynamic>? extraData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPokemonDetails();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    bool fav = await DatabaseHelper.isFavorite(widget.id);
    setState(() => isFavorite = fav);
  }

  Future<void> _loadPokemonDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.id}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          extraData = json.decode(response.body);
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando detalles: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#${widget.id} ${widget.name.toUpperCase()}"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () async {
              if (isFavorite) {
                await DatabaseHelper.removeFavorite(widget.id);
              } else {
                await DatabaseHelper.addFavorite(
                  widget.id,
                  widget.name,
                  widget.imageUrl,
                );
              }
              setState(() => isFavorite = !isFavorite);
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // --- CABECERA CON IMAGEN ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: _getColorByType(
                        extraData!['types'][0]['type']['name'],
                      ).withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(50),
                      ),
                    ),
                    child: Hero(
                      tag: 'poke-${widget.id}',
                      child: Image.network(
                        widget.imageUrl,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- TIPOS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: (extraData!['types'] as List)
                        .map((t) => _buildTypeChip(t['type']['name']))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // --- PESO Y ALTURA (Physical Info) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoColumn(
                        "${extraData!['weight'] / 10} KG",
                        Icons.fitness_center,
                        "PESO",
                      ),
                      _buildInfoColumn(
                        "${extraData!['height'] / 10} M",
                        Icons.height,
                        "ALTURA",
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "ESTADÍSTICAS BASE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // --- BARRAS DE STATS ---
                  _buildStatBar(
                    "HP",
                    extraData!['stats'][0]['base_stat'],
                    Colors.green,
                  ),
                  _buildStatBar(
                    "ATK",
                    extraData!['stats'][1]['base_stat'],
                    Colors.redAccent,
                  ),
                  _buildStatBar(
                    "DEF",
                    extraData!['stats'][2]['base_stat'],
                    Colors.blueAccent,
                  ),
                  _buildStatBar(
                    "SPA",
                    extraData!['stats'][3]['base_stat'],
                    Colors.purpleAccent,
                  ),
                  _buildStatBar(
                    "SPD",
                    extraData!['stats'][4]['base_stat'],
                    Colors.teal,
                  ),
                  _buildStatBar(
                    "VEL",
                    extraData!['stats'][5]['base_stat'],
                    Colors.orange,
                  ),

                  const SizedBox(height: 20),

                  // --- HABILIDADES ---
                  const Text(
                    "HABILIDADES",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: (extraData!['abilities'] as List).map((a) {
                      return Chip(
                        label: Text(
                          a['ability']['name'].toString().toUpperCase(),
                        ),
                        backgroundColor: Colors.grey.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getColorByType(type),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _getColorByType(type).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, IconData icon, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                "$value / 255",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / 255,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorByType(String type) {
    switch (type) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow[800]!;
      case 'poison':
        return Colors.purple;
      case 'ice':
        return Colors.cyanAccent;
      case 'ground':
        return Colors.brown;
      case 'rock':
        return Colors.grey;
      case 'psychic':
        return Colors.pinkAccent;
      case 'dragon':
        return Colors.indigo;
      case 'ghost':
        return Colors.deepPurple;
      case 'fairy':
        return Colors.pink[100]!;
      default:
        return Colors.blueGrey;
    }
  }
}
