import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/database_helper.dart';
import '../models/fichaclinica.dart';
import '../models/persona.dart';
import '../models/reserva.dart';
import '../models/categoria.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class FichaClinicaScreen extends StatefulWidget {
  final Reserva? reserva; // Opcional, para preseleccionar datos de una reserva

  FichaClinicaScreen({this.reserva});

  @override
  _FichaClinicaScreenState createState() => _FichaClinicaScreenState();
}

class _FichaClinicaScreenState extends State<FichaClinicaScreen> {
  List<Reserva> reservas = []; // Lista de reservas
  List<Categoria> categorias = [];
  List<Persona> doctores = [];
  List<Persona> pacientes = [];
  List<FichaClinica> fichasClinicas = []; // Lista de todas las fichas clínicas
  List<FichaClinica> fichasFiltradas = [];
  Reserva? selectedReserva; // Reserva seleccionada
  Categoria? selectedCategoria;
  Persona? selectedDoctor;
  Persona? selectedPaciente;

  final TextEditingController _motivoConsultaController =
      TextEditingController();
  final TextEditingController _diagnostico = TextEditingController();
  final TextEditingController _controllerFecha = TextEditingController();
  final TextEditingController _filtroController = TextEditingController();

  @override
  void dispose() {
    // Es importante limpiar el controlador cuando ya no se necesita
    _motivoConsultaController.dispose();
    _filtroController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadReservas();
    _loadCategorias();
    _loadPersonas();
    _cargarFichasClinicas();
  }

  void _loadReservas() async {
    reservas = await DatabaseHelper.instance.queryAllReservas();
    print("Reservas cargadas: $reservas");
    setState(() {});
  }

  void _loadCategorias() async {
    categorias = await DatabaseHelper.instance.queryAllRows();
    print("Categorías cargadas: $categorias");
    setState(() {});
  }

  void _loadPersonas() async {
    var todasLasPersonas = await DatabaseHelper.instance.queryAllPersonas();
    setState(() {
      doctores = todasLasPersonas.where((p) => p.flagEsDoctor).toList();
      pacientes = todasLasPersonas.where((p) => !p.flagEsDoctor).toList();
    });
  }

  void _cargarFichasClinicas() async {
    fichasClinicas = await DatabaseHelper.instance.queryAllFichasClinicas();
    _filtrarFichas();
  }

  void _filtrarFichas() {
    String filtro = _filtroController.text.toLowerCase();
    fichasFiltradas = fichasClinicas.where((ficha) {
      bool filtroPorNombreApellido =
          ficha.paciente.nombre.toLowerCase().contains(filtro) ||
              ficha.paciente.apellido.toLowerCase().contains(filtro) ||
              ficha.doctor.nombre.toLowerCase().contains(filtro) ||
              ficha.doctor.apellido.toLowerCase().contains(filtro);
      bool filtroPorMotivoDiagnostico =
          ficha.motivoConsulta.toLowerCase().contains(filtro) ||
              ficha.diagnostico.toLowerCase().contains(filtro);
      bool filtroPorFecha = ficha.fecha.toLowerCase().contains(filtro);
      bool filtroPorCategoria =
          ficha.categoria.descripcion.toLowerCase().contains(filtro);

      return filtroPorNombreApellido ||
          filtroPorMotivoDiagnostico ||
          filtroPorFecha ||
          filtroPorCategoria;
    }).toList();
    setState(() {});
  }

  void _exportFichasToPdf() async {
    final pdf = pw.Document();

    // Carga la fuente
    final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttf,
          italic: ttf,
          boldItalic: ttf,
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              [
                'Paciente',
                'Doctor',
                'Fecha',
                'Motivo',
                'Diagnóstico',
                'Categoría'
              ],
              ...fichasFiltradas.map((ficha) => [
                    '${ficha.paciente.nombre} ${ficha.paciente.apellido}',
                    '${ficha.doctor.nombre} ${ficha.doctor.apellido}',
                    ficha.fecha,
                    ficha.motivoConsulta,
                    ficha.diagnostico,
                    ficha.categoria.descripcion,
                  ]),
            ],
          ),
        ],
      ),
    );

    final output = await _localPath;
    final file = File("$output/fichas_clinicas.pdf");
    await file.writeAsBytes(await pdf.save());
  }

  void _exportFichasToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow(
        ['Paciente', 'Doctor', 'Fecha', 'Motivo', 'Diagnóstico', 'Categoría']);

    for (var ficha in fichasFiltradas) {
      sheet.appendRow([
        '${ficha.paciente.nombre} ${ficha.paciente.apellido}',
        '${ficha.doctor.nombre} ${ficha.doctor.apellido}',
        ficha.fecha,
        ficha.motivoConsulta,
        ficha.diagnostico,
        ficha.categoria.descripcion,
      ]);
    }

    final output = await _localPath;
    final file = File("$output/fichas_clinicas.xlsx");

    final bytes = excel.encode();
    await file.writeAsBytes(bytes!);
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Ficha Clínica')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Con Reserva',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<Reserva>(
                value: selectedReserva,
                hint: Text("Seleccione una reserva"),
                onChanged: (Reserva? newValue) {
                  setState(() {
                    selectedReserva = newValue;
                  });
                },
                items:
                    reservas.map<DropdownMenuItem<Reserva>>((Reserva reserva) {
                  return DropdownMenuItem<Reserva>(
                    value: reserva,
                    child: Text(
                        '${reserva.paciente.nombre} - Dr. ${reserva.doctor.nombre}'),
                  );
                }).toList(),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Sin Reserva',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TextField(
              controller: _controllerFecha,
              decoration: InputDecoration(labelText: 'Fecha'),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            DropdownButton<Persona>(
              value: selectedDoctor,
              hint: Text("Seleccione un doctor"),
              onChanged: (Persona? newValue) {
                setState(() {
                  selectedDoctor = newValue;
                });
              },
              items: doctores.map<DropdownMenuItem<Persona>>((Persona doctor) {
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
              items:
                  pacientes.map<DropdownMenuItem<Persona>>((Persona paciente) {
                return DropdownMenuItem<Persona>(
                  value: paciente,
                  child: Text('${paciente.nombre} ${paciente.apellido}'),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _motivoConsultaController,
                decoration: InputDecoration(
                  labelText: 'Motivo de la consulta',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _diagnostico,
                decoration: InputDecoration(
                  labelText: 'Diagnostico',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1, // Ajusta esto según tus necesidades
              ),
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
            ElevatedButton(
              onPressed: _addFichaClinica,
              child: Text('Agregar Ficha'),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Filtros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildFichaList(),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _filtroController,
                decoration: InputDecoration(
                  labelText:
                      'Buscar por nombre, apellido, motivo o diagnóstico',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _filtrarFichas(),
              ),
            ),
            ElevatedButton(
              onPressed:
                  _exportFichasToPdf, // Asegúrate de que esta función esté definida en tu clase
              child: Text('Exportar a PDF'),
            ),
            ElevatedButton(
              onPressed: _exportFichasToExcel,
              child: Text('Exportar a Excel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFichaList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: fichasFiltradas.length,
      itemBuilder: (context, index) {
        var ficha = fichasFiltradas[index];
        return ListTile(
          title: Text(
              '${ficha.paciente.nombre} ${ficha.paciente.apellido} - Dr. ${ficha.doctor.nombre} ${ficha.doctor.apellido}'),
          subtitle: Text(
              '${ficha.motivoConsulta} - ${ficha.diagnostico}, ${ficha.fecha} (${ficha.categoria.descripcion})'),
        );
      },
    );
  }

  void _addFichaClinica() async {
    try {
      if (selectedPaciente != null &&
          selectedCategoria != null &&
          _controllerFecha.text.isNotEmpty &&
          _motivoConsultaController.text.isNotEmpty &&
          _diagnostico.text.isNotEmpty) {
        FichaClinica newFicha = FichaClinica(
          doctor: selectedDoctor!,
          paciente: selectedPaciente!,
          fecha: _controllerFecha.text,
          motivoConsulta: _motivoConsultaController.text,
          diagnostico: _diagnostico.text,
          categoria: selectedCategoria!,
        );
        await DatabaseHelper.instance.insertFichaClinica(newFicha);
        _cargarFichasClinicas(); // Asegúrate de tener este método para recargar la lista de fichas
        _controllerFecha.clear();
        _motivoConsultaController.clear();
        _diagnostico.clear();
      }
    } catch (e) {
      print('Error al guardar la ficha clínica: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la ficha clínica: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
