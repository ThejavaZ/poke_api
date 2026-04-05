import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _database;

  // Singleton: Usamos el getter "database" para asegurar una sola conexión
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit(); // Inicialización necesaria para escritorio
      var databaseFactory = databaseFactoryFfi;
      var databasesPath = await databaseFactory.getDatabasesPath();
      path = join(databasesPath, 'pokedex.db');
    } else {
      path = join(await getDatabasesPath(), 'pokedex.db');
    }

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // Tabla de Favoritos
        await db.execute(
          'CREATE TABLE favorites(id TEXT PRIMARY KEY, name TEXT, imageUrl TEXT)',
        );
        // Tabla de Perfil (ID 1 siempre para el usuario local)
        await db.execute(
          'CREATE TABLE profile(id INTEGER PRIMARY KEY, name TEXT, avatarPath TEXT)',
        );

        // --- TABLAS DE EQUIPOS ---
        await db.execute('''
        CREATE TABLE IF NOT EXISTS teams(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          name TEXT, 
          format TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS team_members(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          team_id INTEGER,
          pokemon_id TEXT,
          pokemon_name TEXT,
          imageUrl TEXT,
          FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS teams(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, format TEXT)',
          );
          await db.execute(
            'CREATE TABLE IF NOT EXISTS team_members(id INTEGER PRIMARY KEY AUTOINCREMENT, team_id INTEGER, pokemon_id TEXT, pokemon_name TEXT, imageUrl TEXT)',
          );
        }
      },
    );
  }
  // --- MÉTODOS DE EQUIPOS ---

  static Future<int> createTeam(String name, String format) async {
    final db = await database;
    return await db.insert('teams', {'name': name, 'format': format});
  }

  static Future<void> addPokemonToTeam(
    int teamId,
    String pokeId,
    String name,
    String url,
  ) async {
    final db = await database;
    // Verificar si ya hay 6 antes de insertar (Lógica de negocio)
    await db.insert('team_members', {
      'team_id': teamId,
      'pokemon_id': pokeId,
      'pokemon_name': name,
      'imageUrl': url,
    });
  }

  static Future<List<Map<String, dynamic>>> getTeamsWithMembers() async {
    final db = await database;
    // Esto es un "Join" manual para simplificar el mapeo en Flutter
    final List<Map<String, dynamic>> teams = await db.query('teams');
    List<Map<String, dynamic>> fullTeams = [];

    for (var team in teams) {
      final members = await db.query(
        'team_members',
        where: 'team_id = ?',
        whereArgs: [team['id']],
      );
      var teamData = Map<String, dynamic>.from(team);
      teamData['pokemons'] = members;
      fullTeams.add(teamData);
    }
    return fullTeams;
  }

  static Future<List<Map<String, dynamic>>> getTeamMembers(int teamId) async {
    final db = await database;
    return await db.query(
      'team_members',
      where: 'team_id = ?',
      whereArgs: [teamId],
    );
  }

  // Y de una vez te paso este para cuando quieras borrar un pokemon del equipo
  static Future<void> removePokemonFromTeam(int memberId) async {
    final db = await database;
    await db.delete('team_members', where: 'id = ?', whereArgs: [memberId]);
  }

  static Future<int> deleteTeam(int teamId) async {
    final db = await database;
    // Gracias al "ON DELETE CASCADE" que pusimos en el CREATE TABLE,
    // al borrar el equipo se deberían borrar sus integrantes automáticamente.
    return await db.delete('teams', where: 'id = ?', whereArgs: [teamId]);
  }
  // --- MÉTODOS DE FAVORITOS ---

  static Future<void> addFavorite(
    String id,
    String name,
    String imageUrl,
  ) async {
    final db = await database;
    await db.insert('favorites', {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  static Future<bool> isFavorite(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  // --- MÉTODOS DE PERFIL (Para el Multiplayer) ---

  static Future<void> saveProfile(String name, String avatarPath) async {
    final db = await database; // Corregido: usamos el getter
    await db.insert('profile', {
      'id': 1,
      'name': name,
      'avatarPath': avatarPath,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final db = await database; // Corregido: usamos el getter
    final List<Map<String, dynamic>> maps = await db.query(
      'profile',
      where: 'id = ?',
      whereArgs: [1],
    );

    return maps.isNotEmpty ? maps.first : null;
  }
}
