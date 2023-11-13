import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/categoria.dart';
import '../models/fichaclinica.dart';
import '../models/persona.dart';
import '../models/reserva.dart';

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

  static final _tableReserva = 'reservas'; // Nombre de la tabla de reservas
  static final columnIdReserva = 'id';
  static final columnDoctor = 'doctor';
  static final columnPaciente = 'paciente';
  static final columnFecha = 'fecha';
  static final columnHora = 'hora';
  static final columnCategoriaReserva = 'categoria';

  // Definiciones para la tabla de fichas clínicas
  static final _tableFichaClinica = 'fichasClinicas';
  static final columnIdFicha = 'id';
  static final columnDoctorFicha = 'doctor';
  static final columnPacienteFicha = 'paciente';
  static final columnFechaFicha = 'fecha';
  static final columnMotivoConsultaFicha = 'motivoConsulta';
  static final columnDiagnosticoFicha = 'diagnostico';
  static final columnCategoriaFicha = 'categoria';
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
    // Crear la tabla de reservas
    await db.execute('''
      CREATE TABLE $_tableReserva (
        $columnIdReserva INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDoctor INTEGER NOT NULL,
        $columnPaciente INTEGER NOT NULL,
        $columnFecha TEXT NOT NULL,
        $columnHora TEXT NOT NULL,
        $columnCategoriaReserva TEXT NOT NULL,
        FOREIGN KEY ($columnDoctor) REFERENCES $_tablePersona($columnIdPersona),
        FOREIGN KEY ($columnPaciente) REFERENCES $_tablePersona($columnIdPersona)
      )
    ''');

    await db.execute('''
    CREATE TABLE $_tableFichaClinica (
      $columnIdFicha INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnDoctorFicha INTEGER NOT NULL,
      $columnPacienteFicha INTEGER NOT NULL,
      $columnFechaFicha TEXT NOT NULL,
      $columnMotivoConsultaFicha TEXT NOT NULL,
      $columnDiagnosticoFicha TEXT NOT NULL,
      $columnCategoriaFicha INTEGER NOT NULL,
      FOREIGN KEY ($columnDoctorFicha) REFERENCES $_tablePersona($columnIdPersona),
      FOREIGN KEY ($columnPacienteFicha) REFERENCES $_tablePersona($columnIdPersona),
      FOREIGN KEY ($columnCategoriaFicha) REFERENCES $_tableName($columnId)
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

  // Métodos para manejar reservas
  Future<int> insertReserva(Reserva reserva) async {
    Database db = await database;
    var map = reserva.toMap();
    map['doctor'] = reserva.doctor
        .idPersona; // Asegúrate de que estos campos coincidan con los nombres de las columnas en la base de datos
    map['paciente'] = reserva.paciente.idPersona;
    return await db.insert(_tableReserva, map);
  }

  Future<Persona> obtenerPersonaPorId(int id) async {
    Database db = await database;
    final res = await db.query(
      _tablePersona,
      where: '$columnIdPersona = ?',
      whereArgs: [id],
    );

    if (res.isNotEmpty) {
      return Persona.fromMap(res.first);
    } else {
      throw Exception('Persona no encontrada');
    }
  }

  Future<List<Reserva>> queryAllReservas() async {
    Database db = await database;
    final res = await db.query(_tableReserva);
    List<Reserva> listaReservas = [];

    for (var reservaMap in res) {
      Persona doctor = await obtenerPersonaPorId(reservaMap['doctor'] as int);
      Persona paciente =
          await obtenerPersonaPorId(reservaMap['paciente'] as int);

      Reserva reserva = Reserva(
        id: reservaMap['id'] as int,
        doctor: doctor,
        paciente: paciente,
        fecha: reservaMap['fecha'] as String,
        hora: reservaMap['hora'] as String,
        categoria: reservaMap['categoria'] as String,
      );

      listaReservas.add(reserva);
    }

    return listaReservas;
  }

  Future<int> updateReserva(Reserva reserva) async {
    Database db = await database;
    return await db.update(_tableReserva, reserva.toMap(),
        where: '$columnIdReserva = ?', whereArgs: [reserva.id]);
  }

  Future<int> deleteReserva(int id) async {
    Database db = await database;
    return await db
        .delete(_tableReserva, where: '$columnIdReserva = ?', whereArgs: [id]);
  }

  Future<List<FichaClinica>> queryAllFichasClinicas() async {
    Database db = await database;
    final res = await db.query(
        _tableFichaClinica); // Asegúrate de que _tableFichaClinica es el nombre correcto de tu tabla
    List<FichaClinica> listaFichas = [];

    for (var fichaMap in res) {
      Persona doctor =
          await obtenerPersonaPorId(fichaMap[columnDoctorFicha] as int);
      Persona paciente =
          await obtenerPersonaPorId(fichaMap[columnPacienteFicha] as int);
      Categoria categoria =
          await obtenerCategoriaPorId(fichaMap[columnCategoriaFicha] as int);

      FichaClinica ficha = FichaClinica.fromMap(fichaMap,
          doctor: doctor, paciente: paciente, categoria: categoria);
      listaFichas.add(ficha);
    }

    return listaFichas;
  }

  Future<Categoria> obtenerCategoriaPorId(int id) async {
    Database db = await database;
    final res = await db.query(
      _tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (res.isNotEmpty) {
      return Categoria.fromMap(res.first);
    } else {
      throw Exception('Categoría no encontrada');
    }
  }

  Future<int> insertFichaClinica(FichaClinica ficha) async {
    Database db = await database;
    var map = {
      'doctor': ficha.doctor.idPersona,
      'paciente': ficha.paciente.idPersona,
      'fecha': ficha.fecha,
      'motivoConsulta': ficha.motivoConsulta,
      'diagnostico': ficha.diagnostico,
      'categoria': ficha.categoria.idCategoria,
    };
    return await db.insert(_tableFichaClinica,
        map); // Cambiado de 'FichaClinica' a '_tableFichaClinica'
  }
}
