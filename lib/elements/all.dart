import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poke_api/elements/pokemon_detail.dart';
import 'package:poke_api/services/database_helper.dart';

class AllView extends StatefulWidget {
  final bool isSelectingForTeam;
  const AllView({super.key, this.isSelectingForTeam = false});

  @override
  State<AllView> createState() => _AllViewState();
}

class _AllViewState extends State<AllView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _pokemons = [];
  String? _selectedType;
  bool _isLoading = false;
  int _offset = 0;

  // Lista de tipos para los Chips
  final List<String> _types = [
    'normal',
    'fire',
    'water',
    'grass',
    'electric',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Solo auto-cargamos si no hay un tipo o búsqueda activa (para no romper la paginación)
      if (!_isLoading &&
          _selectedType == null &&
          _searchController.text.isEmpty) {
        _fetchPokemons();
      }
    }
  }

  // --- LÓGICA DE CARGA ---
  Future<void> _fetchPokemons({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (refresh) {
      _pokemons.clear();
      _offset = 0;
    }

    try {
      final url = _selectedType != null
          ? 'https://pokeapi.co/api/v2/type/$_selectedType'
          : 'https://pokeapi.co/api/v2/pokemon?limit=20&offset=$_offset';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (_selectedType != null) {
            // El endpoint de tipo regresa una estructura diferente
            _pokemons = data['pokemon'].map((p) => p['pokemon']).toList();
          } else {
            _pokemons.addAll(data['results']);
            _offset += 20;
          }
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onTypeSelected(String? type) {
    setState(() {
      _selectedType = (_selectedType == type) ? null : type; // Toggle
    });
    _fetchPokemons(refresh: true);
  }

  String _getPokemonId(String url) {
    return url.split('/').where((s) => s.isNotEmpty).last;
  }

  @override
  Widget build(BuildContext context) {
    // Filtrado local para la búsqueda por nombre sobre lo ya cargado
    final displayList = _pokemons.where((p) {
      return p['name'].toString().toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.isSelectingForTeam
          ? AppBar(title: const Text("Seleccionar Integrante"))
          : null,
      body: Column(
        children: [
          // 1. BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SearchBar(
              controller: _searchController,
              hintText: "Buscar Pokémon...",
              leading: const Icon(Icons.search),
              onChanged: (_) => setState(() {}),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(
                Colors.grey.withOpacity(0.1),
              ),
            ),
          ),

          // 2. FILTRO DE TIPOS (CHIPS)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final type = _types[index];
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(type.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) => _onTypeSelected(type),
                    selectedColor: _getColorByType(type).withOpacity(0.3),
                    checkmarkColor: _getColorByType(type),
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _getColorByType(type) : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. LISTADO
          Expanded(
            child: _isLoading && _pokemons.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: displayList.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < displayList.length) {
                        final pokemon = displayList[index];
                        final id = _getPokemonId(pokemon['url']);
                        final imageUrl =
                            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png";

                        return ListTile(
                          leading: Image.network(
                            imageUrl,
                            width: 50,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.help),
                          ),
                          title: Text(
                            pokemon['name'].toString().toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("#$id"),
                          trailing: widget.isSelectingForTeam
                              ? const Icon(Icons.add, color: Colors.green)
                              : const Icon(Icons.chevron_right),
                          onTap: () {
                            if (widget.isSelectingForTeam) {
                              Navigator.pop(context, {
                                'id': id,
                                'name': pokemon['name'],
                                'imageUrl': imageUrl,
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PokemonDetailView(
                                    name: pokemon['name'],
                                    imageUrl: imageUrl,
                                    id: id,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getColorByType(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.amber;
      case 'ice':
        return Colors.cyan;
      case 'fighting':
        return Colors.orange;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'rock':
        return Colors.blueGrey;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen;
      case 'ghost':
        return Colors.indigo;
      case 'dragon':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
