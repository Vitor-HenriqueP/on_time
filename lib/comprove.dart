import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para verificar se está rodando na web
import 'dart:html' as html; // Para download em web
import 'package:cloud_firestore/cloud_firestore.dart'; // Importando o Firestore

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const ComproveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ponto') // Coleção que armazena os registros
                    .orderBy('hora', descending: true) // Ordenar por hora
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum registro encontrado.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final registros = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: registros.length,
                    itemBuilder: (context, index) {
                      final registro = registros[index];
                      final timestamp = registro['hora'] as Timestamp;
                      final hora = DateFormat('HH:mm').format(timestamp.toDate());
                      final dia = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(timestamp.toDate());

                      return Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Horário: $hora', style: const TextStyle(color: Colors.white)),
                            Text('Dia: $dia', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await _generateAndDownloadPDF();
              },
              icon: const Icon(Icons.cloud_download, color: Colors.orange),
              label: const Text('Baixar comprovante'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
              ),
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
      backgroundColor: Colors.black,
    );
  }

 Future<void> _generateAndDownloadPDF() async {
  // Recuperar todos os registros do Firestore
  final querySnapshot = await FirebaseFirestore.instance
      .collection('ponto')
      .orderBy('hora', descending: true)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    final pdf = pw.Document();

    // Adiciona uma página ao PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          final List<pw.Widget> content = [];
          final nome = 'Vitor Henrique'; // Você pode substituir isso pela variável real, se necessário
          final matricula = '123456789'; // Substitua isso pela matrícula real, se disponível

          content.add(pw.Text('Nome: $nome', style: pw.TextStyle(fontSize: 20)));
          content.add(pw.Text('Matrícula: $matricula', style: pw.TextStyle(fontSize: 20)));
          content.add(pw.SizedBox(height: 20));

          // Adiciona cada registro ao PDF
          for (final registro in querySnapshot.docs) {
            final timestamp = registro['hora'] as Timestamp;
            final hora = DateFormat('HH:mm:ss').format(timestamp.toDate());
            final dia = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(timestamp.toDate());

            content.add(pw.Text('Horário: $hora'));
            content.add(pw.Text('Dia: $dia'));
            content.add(pw.SizedBox(height: 10)); // Espaçamento entre registros
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: content,
          );
        },
      ),
    );

    if (kIsWeb) {
      // Web: inicia o download
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: ur
        ..setAttribute('download', 'comprovante.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile/desktop: salva em um diretório temporário e abre o arquivo
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/comprovante.pdf");
      await file.writeAsBytes(await pdf.save());

      // Exibir uma mensagem de confirmação
      print('PDF salvo em ${file.path}');
    }
  } else {
    print('Nenhum registro encontrado para gerar o PDF.');
  }
}
}