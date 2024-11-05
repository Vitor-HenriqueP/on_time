import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
//test
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Demo',
      initialRoute: '/comprove',
      routes: {
        '/comprove': (context) => const ComproveScreen(),
      },
    );
  }
}

class ComproveScreen extends StatelessWidget {
  const ComproveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olá, Vitor!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
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
            const Text(
              'Comprovante de registro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nome: Vitor Henrique', style: TextStyle(color: Colors.white)),
                  Text('Matrícula: 123456789', style: TextStyle(color: Colors.white)),
                  Text('Horário: 13:28:42', style: TextStyle(color: Colors.white)),
                  Text('Dia: 31 de Outubro de 2024', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Action to download comprovante
              },
              icon: const Icon(Icons.download),
              label: const Text('Baixar comprovante'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
