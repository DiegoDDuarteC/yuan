class Categoria {
  int idCategoria;
  String descripcion;

  Categoria({required this.idCategoria, required this.descripcion});

  // Convert a Categoria into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'idCategoria': idCategoria,
      'descripcion': descripcion,
    };
  }

  // Convert a Map into a Categoria. The keys must correspond to the names of the columns in the database.
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      idCategoria: map['idCategoria'],
      descripcion: map['descripcion'],
    );
  }
}
