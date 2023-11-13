import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  List<Map<String, String>> data = [
    {"Doctor": "Dr. Smith", "Paciente": "John Doe", "Fecha": "2023-11-12", "Categoría": "Consulta"},
    {"Doctor": "Dr. Johnson", "Paciente": "Jane Doe", "Fecha": "2023-11-13", "Categoría": "Examen"},
  ];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void _exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      build: (context) => [
        pw.Table.fromTextArray(context: context, data: <List<String>>[
          ['Doctor', 'Paciente', 'Fecha', 'Categoría'],
          for (var item in data) [item['Doctor']!, item['Paciente']!, item['Fecha']!, item['Categoría']!],
        ]),
      ],
    ));

    final output = await _localPath;
    final file = File("$output/example.pdf");
    await file.writeAsBytes(await pdf.save());
  }

  void _exportToExcel() async {
    final excel = Excel.createExcel();

    final sheet = excel['Sheet1'];
    sheet.appendRow(['Doctor', 'Paciente', 'Fecha', 'Categoría']);

    for (var item in data) {
      sheet.appendRow([item['Doctor']!, item['Paciente']!, item['Fecha']!, item['Categoría']!]);
    }

    final output = await _localPath;
    final file = File("$output/example.xlsx");

    final bytes = excel.encode();
    await file.writeAsBytes(bytes!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabla Flutter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DataTable(
              columns: [
                DataColumn(label: Text('Doctor')),
                DataColumn(label: Text('Paciente')),
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Categoría')),
              ],
              rows: data.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item['Doctor']!)),
                  DataCell(Text(item['Paciente']!)),
                  DataCell(Text(item['Fecha']!)),
                  DataCell(Text(item['Categoría']!)),
                ]);
              }).toList(),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _exportToPdf,
                  child: Text('Exportar a PDF'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _exportToExcel,
                  child: Text('Exportar a Excel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
