import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/editPontoScreen.dart';
import 'package:intl/intl.dart';

class PontoScreen extends StatelessWidget {
  final String email;

  PontoScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Ponto'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            );
          }

          final registros = snapshot.data!.docs;

          final filteredRegistros = email == 'teste@teste.com.br'
              ? registros
              : registros.where((registro) {
                  final emailRegistro = registro['email'];
                  return emailRegistro == email;
                }).toList();

          if (filteredRegistros.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum registro encontrado para o usuário logado.',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredRegistros.length,
            itemBuilder: (context, index) {
              final registro = filteredRegistros[index];
              final hora = (registro['hora'] as Timestamp).toDate();
              final email = registro['email'];

              return ListTile(
                title: Text(
                  'Hora: ${DateFormat('HH:mm:ss').format(hora)}',
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                subtitle: Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(hora)}\nUsuário: $email',
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                onTap: () {
                  // Navega para a tela de detalhes com o registro selecionado
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhePontoScreen(
                        registro: registro,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
