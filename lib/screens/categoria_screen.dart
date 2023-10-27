import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../helpers/database_helper.dart';

class CategoriaScreen extends StatefulWidget {
  @override
  _CategoriaScreenState createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  List<Categoria> categorias = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  void _loadCategorias() async {
    categorias = await DatabaseHelper.instance.queryAllRows();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administración de Categorías')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Descripción',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCategoria,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categorias[index].descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editCategoria(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            _deleteCategoria(categorias[index].idCategoria),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addCategoria() async {
    if (_controller.text.isNotEmpty) {
      Categoria newCategoria = Categoria(
          idCategoria: 0,
          descripcion:
              _controller.text); // id 0 porque SQLite lo autoincrementará
      await DatabaseHelper.instance.insert(newCategoria);
      _loadCategorias();
      _controller.clear();
    }
  }

  void _deleteCategoria(int id) async {
    await DatabaseHelper.instance.delete(id);
    _loadCategorias();
  }

  void _editCategoria(int index) async {
    _controller.text = categorias[index].descripcion;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Categoría'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Descripción'),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  categorias[index].descripcion = _controller.text;
                  await DatabaseHelper.instance.update(categorias[index]);
                  _loadCategorias();
                  Navigator.of(context).pop();
                  _controller.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
