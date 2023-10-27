import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../helpers/database_helper.dart';

class PersonaScreen extends StatefulWidget {
  @override
  _PersonaScreenState createState() => _PersonaScreenState();
}

class _PersonaScreenState extends State<PersonaScreen> {
  List<Persona> personas = [];
  TextEditingController _controllerNombre = TextEditingController();
  TextEditingController _controllerApellido = TextEditingController();
  bool _showOnlyDoctors = false;

  @override
  void initState() {
    super.initState();
    _loadPersonas();
  }

  void _loadPersonas() async {
    personas = await DatabaseHelper.instance.queryAllPersonas();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administración de Personas'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showOnlyDoctors = !_showOnlyDoctors;
              });
              _loadPersonas();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _controllerNombre,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _controllerApellido,
                  decoration: InputDecoration(labelText: 'Apellido'),
                ),
                Row(
                  children: [
                    Text('Es doctor?'),
                    Switch(
                      value: _showOnlyDoctors,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyDoctors = value;
                        });
                      },
                    ),
                    ElevatedButton(
                      child: Text('Agregar'),
                      onPressed: _addPersona,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: personas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      '${personas[index].nombre} ${personas[index].apellido}'),
                  subtitle: Text(
                      personas[index].flagEsDoctor ? 'Doctor' : 'Paciente'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editPersona(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () =>
                            _deletePersona(personas[index].idPersona),
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

  void _addPersona() async {
    if (_controllerNombre.text.isNotEmpty &&
        _controllerApellido.text.isNotEmpty) {
      Persona newPersona = Persona(
        idPersona: 0,
        nombre: _controllerNombre.text,
        apellido: _controllerApellido.text,
        telefono: '',
        email: '',
        cedula: '',
        flagEsDoctor: _showOnlyDoctors,
      );
      await DatabaseHelper.instance.insertPersona(newPersona);
      _loadPersonas();
      _controllerNombre.clear();
      _controllerApellido.clear();
    }
  }

  void _editPersona(int index) async {
    _controllerNombre.text = personas[index].nombre;
    _controllerApellido.text = personas[index].apellido;
    bool isDoctor = personas[index].flagEsDoctor;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Persona'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controllerNombre,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _controllerApellido,
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              Row(
                children: [
                  Text('Es doctor?'),
                  Switch(
                    value: isDoctor,
                    onChanged: (value) {
                      setState(() {
                        isDoctor = value;
                      });
                    },
                  ),
                ],
              ),
            ],
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
                if (_controllerNombre.text.isNotEmpty &&
                    _controllerApellido.text.isNotEmpty) {
                  personas[index].nombre = _controllerNombre.text;
                  personas[index].apellido = _controllerApellido.text;
                  personas[index].flagEsDoctor = isDoctor;

                  await DatabaseHelper.instance.updatePersona(personas[index]);
                  _loadPersonas();
                  Navigator.of(context).pop();
                  _controllerNombre.clear();
                  _controllerApellido.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePersona(int id) async {
    await DatabaseHelper.instance.deletePersona(id);
    _loadPersonas();
  }
}
