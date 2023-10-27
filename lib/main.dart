import 'package:flutter/material.dart';
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
            ElevatedButton(
              child: Text('Administrar Categorías'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CategoriaScreen(),
                ));
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Administrar Personas'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PersonaScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
