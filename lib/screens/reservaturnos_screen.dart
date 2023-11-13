import 'package:flutter/material.dart';
import 'package:yuan/models/reserva.dart';
import 'package:yuan/models/categoria.dart';
import 'package:yuan/models/persona.dart';
import 'package:yuan/helpers/database_helper.dart';

class ReservaScreen extends StatefulWidget {
  @override
  _ReservaScreenState createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  List<Categoria> categorias = [];
  List<Persona> doctores = [];
  List<Persona> pacientes = [];
  List<Reserva> reservas = [];
  Persona? selectedDoctor;
  Persona? selectedPaciente;
  Categoria? selectedCategoria;
  final TextEditingController _controllerFecha = TextEditingController();
  final TextEditingController _controllerHora = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    _loadPersonas();
    _loadReservas();
  }

  void _loadCategorias() async {
    categorias = await DatabaseHelper.instance.queryAllRows();
    setState(() {});
  }

  void _loadPersonas() async {
    var todasLasPersonas = await DatabaseHelper.instance.queryAllPersonas();
    setState(() {
      doctores = todasLasPersonas.where((p) => p.flagEsDoctor).toList();
      pacientes = todasLasPersonas.where((p) => !p.flagEsDoctor).toList();
    });
  }

  void _loadReservas() async {
    reservas = await DatabaseHelper.instance.queryAllReservas();
    print("Reservas cargadas: $reservas"); // Agregar para depuración
    setState(() {});
  }

  void _deleteReserva(int? id) async {
    if (id != null) {
      await DatabaseHelper.instance.deleteReserva(id);
      _loadReservas(); // Recargar la lista de reservas
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administración de Reservas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownButton<Persona>(
                  value: selectedDoctor,
                  hint: Text("Seleccione un doctor"),
                  onChanged: (Persona? newValue) {
                    setState(() {
                      selectedDoctor = newValue;
                    });
                  },
                  items:
                      doctores.map<DropdownMenuItem<Persona>>((Persona doctor) {
                    return DropdownMenuItem<Persona>(
                      value: doctor,
                      child: Text('${doctor.nombre} ${doctor.apellido}'),
                    );
                  }).toList(),
                ),
                DropdownButton<Persona>(
                  value: selectedPaciente,
                  hint: Text("Seleccione un paciente"),
                  onChanged: (Persona? newValue) {
                    setState(() {
                      selectedPaciente = newValue;
                    });
                  },
                  items: pacientes
                      .map<DropdownMenuItem<Persona>>((Persona paciente) {
                    return DropdownMenuItem<Persona>(
                      value: paciente,
                      child: Text('${paciente.nombre} ${paciente.apellido}'),
                    );
                  }).toList(),
                ),
                DropdownButton<Categoria>(
                  value: selectedCategoria,
                  hint: Text("Seleccione una categoría"),
                  onChanged: (Categoria? newValue) {
                    setState(() {
                      selectedCategoria = newValue;
                    });
                  },
                  items: categorias
                      .map<DropdownMenuItem<Categoria>>((Categoria categoria) {
                    return DropdownMenuItem<Categoria>(
                      value: categoria,
                      child: Text(categoria.descripcion),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _controllerFecha,
                  decoration: InputDecoration(labelText: 'Fecha'),
                ),
                TextField(
                  controller: _controllerHora,
                  decoration: InputDecoration(labelText: 'Hora'),
                ),
                ElevatedButton(
                  onPressed: _addReserva,
                  child: Text('Agregar Reserva'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                return ListTile(
                    title: Text(
                        '${reserva.doctor.nombre} - ${reserva.paciente.nombre}'),
                    subtitle: Text('${reserva.fecha} - ${reserva.hora}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteReserva(reservas[index].id),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addReserva() async {
    try {
      if (selectedDoctor != null &&
          selectedPaciente != null &&
          selectedCategoria != null &&
          _controllerFecha.text.isNotEmpty &&
          _controllerHora.text.isNotEmpty) {
        Reserva newReserva = Reserva(
          //id: 0,
          doctor: selectedDoctor!,
          paciente: selectedPaciente!,
          fecha: _controllerFecha.text,
          hora: _controllerHora.text,
          categoria: selectedCategoria!.descripcion,
        );
        await DatabaseHelper.instance.insertReserva(newReserva);
        _loadReservas();
        _controllerFecha.clear();
        _controllerHora.clear();
      }
    } catch (e) {
      print('Error al guardar la reserva: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la reserva: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
