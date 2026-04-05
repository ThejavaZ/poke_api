import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final Function(int) onSubPageChange;

  const DashboardPage({super.key, required this.onSubPageChange});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lógica de columnas: 2 para móvil, 3 para tablet, 4+ para escritorio
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // Ajustamos el aspect ratio para que no se vean tan altos en escritorio
            childAspectRatio: constraints.maxWidth > 600 ? 1.2 : 1.0,
            children: [
              _buildCategoryCard(
                context,
                title: "Todos",
                subtitle: "Pokedex completa",
                icon: Icons.catching_pokemon,
                color: Colors.redAccent,
                onTap: () => onSubPageChange(3),
              ),
              _buildCategoryCard(
                context,
                title: "Generaciones",
                subtitle: "Kanto, Johto y más",
                icon: Icons.history_edu,
                color: Colors.blueAccent,
                onTap: () => onSubPageChange(4),
              ),
              _buildCategoryCard(
                context,
                title: "Tipos",
                subtitle: "Fuego, Agua, etc.",
                icon: Icons.bolt,
                color: Colors.orangeAccent,
                onTap: () => onSubPageChange(5),
              ),
              _buildCategoryCard(
                context,
                title: "Legendarios",
                subtitle: "Los más poderosos",
                icon: Icons.auto_awesome,
                color: Colors.amber,
                onTap: () => onSubPageChange(6),
              ),
              _buildCategoryCard(
                context,
                title: "Favoritos",
                subtitle: "Tus capturas",
                icon: Icons.favorite,
                color: Colors.pinkAccent,
                onTap: () => onSubPageChange(7),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.8), color],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Un icono de fondo grande y semitransparente para dar estilo
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
