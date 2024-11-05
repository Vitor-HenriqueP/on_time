import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para verificar se está rodando na web
import 'dart:html' as html; // Para download em web
import 'package:cloud_firestore/cloud_firestore.dart'; // Importando o Firestore

class DetalheRegistroScreen extends StatelessWidget {
  final String hora;
  final String dia;

  const DetalheRegistroScreen({super.key, required this.hora, required this.dia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Detalhe do Registro'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Horário: $hora', style: const TextStyle(fontSize: 18, color: Colors.white)),
              Text('Dia: $dia', style: const TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await _generateAndDownloadPDF(hora, dia);
                },
                icon: const Icon(Icons.cloud_download, color: Colors.orange),
                label: const Text('Salvar Registro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Future<void> _generateAndDownloadPDF(String hora, String dia) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Detalhe do Registro', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Horário: $hora', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Dia: $dia', style: pw.TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
    );

    if (kIsWeb) {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'detalhe_registro.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/detalhe_registro.pdf");
      await file.writeAsBytes(await pdf.save());
      print('PDF salvo em ${file.path}');
    }
  }
}
