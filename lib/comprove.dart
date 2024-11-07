import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _downloadIndividualPdf(QueryDocumentSnapshot registro) async {
    final pdf = pw.Document();
    final timestamp = registro['hora'] as Timestamp;
    final hora = DateFormat('HH:mm').format(timestamp.toDate());
    final dia = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
        .format(timestamp.toDate());
    final email = registro['email'];

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Comprovante de Registro',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Hora: $hora', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Data: $dia', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Email: $email', style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );

    if (kIsWeb) {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'registro_$hora.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/registro_$hora.pdf");
      await file.writeAsBytes(await pdf.save());
      print("PDF salvo em ${file.path}");
    }
  }

  Future<void> _downloadAllRecordsPdf(
      List<QueryDocumentSnapshot> registros) async {
    final pdf = pw.Document();

    // Adicionando o título e registros todos na mesma página
    List<pw.Widget> registroWidgets = [
      pw.Text('Comprovante de Registros',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 20), // Espaço abaixo do título
    ];

    // Adicionando os registros
    for (var registro in registros) {
      final timestamp = registro['hora'] as Timestamp;
      final hora = DateFormat('HH:mm').format(timestamp.toDate());
      final dia = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
          .format(timestamp.toDate());
      final email = registro['email'];

      registroWidgets.addAll([
        pw.Text('Hora: $hora', style: pw.TextStyle(fontSize: 16)),
        pw.Text('Data: $dia', style: pw.TextStyle(fontSize: 16)),
        pw.Text('Email: $email', style: pw.TextStyle(fontSize: 16)),
        pw.SizedBox(height: 10), // Espaço entre os registros
      ]);
    }

    // Criando uma única página com todos os registros
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: registroWidgets,
        ),
      ),
    );

    // Salvar e baixar o PDF
    if (kIsWeb) {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'registros_comprovantes.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/registros_comprovantes.pdf");
      await file.writeAsBytes(await pdf.save());
      print("PDF salvo em ${file.path}");
    }
  }

  void _showRegistroDialog(
      BuildContext context, QueryDocumentSnapshot registro) {
    final timestamp = registro['hora'] as Timestamp;
    final hora = DateFormat('HH:mm').format(timestamp.toDate());
    final dia = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
        .format(timestamp.toDate());
    final email = registro['email'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalhes do Registro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hora: $hora'),
              Text('Data: $dia'),
              Text('Email: $email'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text(
                "Baixar",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              onPressed: () async {
                await _downloadIndividualPdf(registro);
                Navigator.of(context).pop(); // Fecha o diálogo após o download
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;

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
      body: Container(
        color: Colors.grey, // Fundo preto
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Comprovante de registro',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ponto')
                    .orderBy('hora', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum registro encontrado.',
                        style: TextStyle(color: Color(0xFFF4F4F4)),
                      ),
                    );
                  }

                  final registros = snapshot.data!.docs;
                  final filteredRegistros = userEmail == 'teste@teste.com.br'
                      ? registros
                      : registros.where((registro) {
                          final email = registro['email'];
                          return email == userEmail;
                        }).toList();

                  if (filteredRegistros.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum registro encontrado para o usuário logado.',
                        style: TextStyle(color: Color(0xFFF4F4F4)),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text(
                          "Baixar Todos",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () async {
                          await _downloadAllRecordsPdf(filteredRegistros);
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredRegistros.length,
                          itemBuilder: (context, index) {
                            final registro = filteredRegistros[index];
                            final timestamp = registro['hora'] as Timestamp;
                            final hora =
                                DateFormat('HH:mm').format(timestamp.toDate());
                            final dia = DateFormat(
                                    'dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
                                .format(timestamp.toDate());
                            final email = registro['email'];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Card(
                                color: const Color(0xFF433D3D),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.access_time,
                                    color: Color(0xFFFF8A50),
                                  ),
                                  title: Center(
                                    child: Text(
                                      hora,
                                      style: const TextStyle(
                                          color: Color(0xFFF4F4F4)),
                                    ),
                                  ),
                                  subtitle: Center(
                                    child: Text(
                                      dia,
                                      style: const TextStyle(
                                          color: Color(0xFFF4F4F4)),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility,
                                            color: Colors.orange),
                                        onPressed: () => _showRegistroDialog(
                                            context, registro),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
