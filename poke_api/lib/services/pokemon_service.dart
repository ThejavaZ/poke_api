import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonService {
  Future<List<dynamic>> fetchPokemons(int offset) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=10&offset=$offset'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Error al cargar pokemones');
    }
  }

  static Future<List<dynamic>> fetchGenerations() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/generation/'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    }
    return [];
  }
}
