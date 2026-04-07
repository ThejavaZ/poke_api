import 'package:flutter/material.dart';
import 'package:poke_api/services/database_helper.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  // Asegúrate de que este nombre sea exactamente igual al de abajo
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.getFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  "Aún no tienes pokémones favoritos",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final favorites = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final pokemon = favorites[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: Hero(
                  tag: 'fav-${pokemon['id']}',
                  child: Image.network(
                    pokemon['imageUrl'],
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                title: Text(
                  pokemon['name'].toString().toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("ID: #${pokemon['id']}"),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () async {
                    // Borramos de la DB
                    await DatabaseHelper.removeFavorite(pokemon['id']);
                    // Refrescamos la UI
                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Eliminado de tus favoritos"),
                      ),
                    );
                  },
                ),
                onTap: () {
                  // Aquí podrías navegar de vuelta al DetailView si quieres
                },
              ),
            );
          },
        );
      },
    );
  }
}
