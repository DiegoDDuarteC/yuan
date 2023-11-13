import './persona.dart';
import './reserva.dart';
import 'categoria.dart';

class FichaClinica {
  int? id;
  Persona doctor;
  Persona paciente;
  String fecha;
  String motivoConsulta;
  String diagnostico;
  Categoria categoria;

  FichaClinica({
    this.id,
    required this.doctor,
    required this.paciente,
    required this.fecha,
    required this.motivoConsulta,
    required this.diagnostico,
    required this.categoria,
  });

  static FichaClinica fromMap(Map<String, dynamic> map,
      {required Persona doctor,
      required paciente,
      required Categoria categoria}) {
    return FichaClinica(
      id: map['id'],
      doctor: doctor,
      paciente: paciente,
      fecha: map['fecha'],
      motivoConsulta: map['motivoConsulta'],
      diagnostico: map['diagnostico'],
      categoria: categoria,
    );
  }

  // Métodos para convertir a y desde Map, similar a tus otros modelos
}
