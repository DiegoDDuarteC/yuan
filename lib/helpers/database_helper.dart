import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/categoria.dart';
import '../models/persona.dart';

class DatabaseHelper {
  static final _dbName = 'fichasClinicas.db';
  static final _dbVersion = 1;
  static final _tableName = 'categorias';

  static final columnId = 'idCategoria';
  static final columnDescripcion = 'descripcion';

  //para Persona
  static final _tablePersona = 'personas';
  static final columnIdPersona = 'idPersona';
  static final columnName = 'nombre';
  static final columnApellido = 'apellido';
  static final columnTelefono = 'telefono';
  static final columnEmail = 'email';
  static final columnCedula = 'cedula';
  static final columnFlagEsDoctor = 'flagEsDoctor';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $_tableName (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnDescripcion TEXT NOT NULL
    )
    ''');

    await db.execute('''
      CREATE TABLE $_tablePersona (
        $columnIdPersona INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnApellido TEXT NOT NULL,
        $columnTelefono TEXT,
        $columnEmail TEXT,
        $columnCedula TEXT NOT NULL,
        $columnFlagEsDoctor INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insert(Categoria categoria) async {
    Database db = await database;
    var map = categoria.toMap();
    map.remove('idCategoria'); // Remove the ID so SQLite can auto-generate it
    return await db.insert(_tableName, map);
  }

  Future<List<Categoria>> queryAllRows() async {
    Database db = await database;
    final res = await db.query(_tableName);
    return res.isNotEmpty ? res.map((c) => Categoria.fromMap(c)).toList() : [];
  }

  Future<int> update(Categoria categoria) async {
    Database db = await database;
    return await db.update(_tableName, categoria.toMap(),
        where: '$columnId = ?', whereArgs: [categoria.idCategoria]);
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(_tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  // Insert a new person
  Future<int> insertPersona(Persona persona) async {
    Database db = await database;
    var map = persona.toMap();
    map.remove('idPersona');
    return await db.insert(_tablePersona, map);
  }

  // Get all persons
  Future<List<Persona>> queryAllPersonas() async {
    Database db = await database;
    final res = await db.query(_tablePersona);
    return res.isNotEmpty ? res.map((c) => Persona.fromMap(c)).toList() : [];
  }

  // Update a person
  Future<int> updatePersona(Persona persona) async {
    Database db = await database;
    return await db.update(_tablePersona, persona.toMap(),
        where: '$columnIdPersona = ?', whereArgs: [persona.idPersona]);
  }

  // Delete a person
  Future<int> deletePersona(int id) async {
    Database db = await database;
    return await db
        .delete(_tablePersona, where: '$columnIdPersona = ?', whereArgs: [id]);
  }
}
