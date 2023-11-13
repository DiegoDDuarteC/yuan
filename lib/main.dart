import 'package:flutter/material.dart';
import 'package:yuan/models/fichaclinica.dart';
import 'package:yuan/screens/fichaclinica_screen.dart';
import 'package:yuan/screens/reservaturnos_screen.dart';
import 'screens/categoria_screen.dart';
import 'screens/persona_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fichas Clínicas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fichas Clínicas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200, // Ancho fijo para todos los botones
              child: ElevatedButton(
                child: Text('Administrar Categorías'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CategoriaScreen(),
                  ));
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200, // Ancho fijo para todos los botones
              child: ElevatedButton(
                child: Text('Administrar Personas'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PersonaScreen(),
                  ));
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200, // Ancho fijo para todos los botones
              child: ElevatedButton(
                child: Text('Reserva de turnos'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReservaScreen(),
                  ));
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200, // Ancho fijo para todos los botones
              child: ElevatedButton(
                child: Text('Ficha Clínica'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FichaClinicaScreen(),
                  ));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
