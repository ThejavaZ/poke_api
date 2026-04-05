import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          ListTile(
            leading: const Icon(Icons.catching_pokemon_sharp),
            title: const Text("Todos los pokemons"),
            subtitle: const Text("Todos los pokemons"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text("Todos los pokemons"),
            subtitle: const Text("Todos los pokemons"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text("Por tipos"),
            subtitle: const Text("Por tipos"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.star),
            title: const Text("Legendarios"),
            subtitle: const Text("Los legendarios"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text("Favoritos"),
            subtitle: const Text("Tus pokemones favoritos"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
