import 'package:flutter/material.dart';
import './persona.dart';
import '../helpers/database_helper.dart';

class Reserva {
  late int? id; // ID único de la reserva
  Persona doctor; // Nombre del doctor
  Persona paciente; // Nombre del paciente
  String fecha; // Fecha de la reserva
  String hora; // Horario de la reserva (por ejemplo, "09:00 - 10:00")
  String categoria; //Descripcion de la categoria*/

  Reserva({
    this.id,
    required this.doctor,
    required this.paciente,
    required this.fecha,
    required this.hora,
    required this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor': doctor,
      'paciente': paciente,
      'fecha': fecha,
      'hora': hora,
      'categoria': categoria,
    };
  }

  factory Reserva.fromMap(Map<String, dynamic> map) {
    return Reserva(
      id: map['id'],
      doctor: map['doctor'],
      paciente: map['paciente'],
      fecha: map['fecha'],
      hora: map['hora'],
      categoria: map['categoria'],
    );
  }
}
