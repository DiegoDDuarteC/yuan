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
  String? selectedHora;
  final List<String> horarios = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
    '20:00 - 21:00',
  ];
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _controllerFecha.text = "${picked.toLocal()}".split(' ')[0];
      });
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
                  readOnly:
                      true, // Hace que el campo de texto sea de solo lectura
                  onTap: () => _selectDate(
                      context), // Abre el selector de fecha al tocar
                ),
                DropdownButton<String>(
                  value: selectedHora,
                  hint: Text("Seleccione un horario"),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedHora = newValue;
                    });
                  },
                  items: horarios.map<DropdownMenuItem<String>>((String hora) {
                    return DropdownMenuItem<String>(
                      value: hora,
                      child: Text(hora),
                    );
                  }).toList(),
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
                        'Dr. ${reserva.doctor.nombre} ${reserva.doctor.apellido} - ${reserva.paciente.nombre} ${reserva.paciente.apellido}'),
                    subtitle: Text(
                        '${reserva.fecha} - ${reserva.hora} - ${reserva.categoria}'),
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
          selectedHora != null) {
        Reserva newReserva = Reserva(
          //id: 0,
          doctor: selectedDoctor!,
          paciente: selectedPaciente!,
          fecha: _controllerFecha.text,
          hora: selectedHora!,
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
