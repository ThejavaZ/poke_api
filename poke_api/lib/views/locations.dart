import 'package:flutter/material.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos simulados de regiones icónicas
    final List<Map<String, dynamic>> regions = [
      {
        'name': 'Kanto',
        'locations': 15,
        'color': Colors.redAccent,
        'icon': Icons.landscape,
      },
      {
        'name': 'Johto',
        'locations': 12,
        'color': Colors.blueAccent,
        'icon': Icons.tsunami,
      },
      {
        'name': 'Hoenn',
        'locations': 20,
        'color': Colors.greenAccent.shade700,
        'icon': Icons.forest,
      },
      {
        'name': 'Sinnoh',
        'locations': 18,
        'color': Colors.lightBlue,
        'icon': Icons.ac_unit,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Un header bonito que invite a explorar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "EXPLORAR REGIONES",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "Descubre dónde encontrar a tus Pokémon favoritos",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          // Lista de regiones con diseño de "Banner"
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final region = regions[index];
                return _buildRegionCard(region);
              }, childCount: regions.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionCard(Map<String, dynamic> region) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [region['color'].withOpacity(0.8), region['color']],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: region['color'].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Icono de fondo decorativo
          Positioned(
            top: -10,
            right: -10,
            child: Icon(
              region['icon'],
              size: 140,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  region['name'].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight(1),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${region['locations']} Áreas disponibles",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pequeño fix tipográfico para el Positioned que escribí arriba (Positionpoint no existe, es Positioned)
