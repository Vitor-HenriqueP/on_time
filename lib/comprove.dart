import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Demo',
      initialRoute: '/comprove',
      routes: {
        '/comprove': (context) => ComproveScreen(),
      },
    );
  }
}

class ComproveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, Vitor!'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Action for menu button
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Comprovante de registro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: Vitor Henrique', style: TextStyle(color: Colors.white)),
                  Text('Matrícula: 123456789', style: TextStyle(color: Colors.white)),
                  Text('Horário: 13:28:42', style: TextStyle(color: Colors.white)),
                  Text('Dia: 31 de Outubro de 2024', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Action to download comprovante
              },
              icon: Icon(Icons.download),
              label: Text('Baixar comprovante'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
