import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para verificar se está rodando na web
import 'dart:html' as html; // Para download em web

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
        backgroundColor: Colors.grey[900],
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                  Text('Nome: Vitor Henrique', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('Matrícula: 123456789', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('Horário: 13:28:42', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('Dia: 31 de Outubro de 2024', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await _generateAndDownloadPDF();
              },
              icon: Icon(Icons.cloud_download, color: Colors.orange),
              label: Text('Baixar comprovante'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
              ),
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
      backgroundColor: Colors.black,
    );
  }

  Future<void> _generateAndDownloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Nome: Vitor Henrique'),
              pw.Text('Matrícula: 123456789'),
              pw.Text('Horário: 13:28:42'),
              pw.Text('Dia: 31 de Outubro de 2024'),
            ],
          ),
        ),
      ),
    );

    if (kIsWeb) {
      // Web: inicia o download
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
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
  }
}
