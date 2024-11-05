import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF433D3D),
      appBar: AppBar(
        title: const Text('Minhas Solicitações'),
        backgroundColor: const Color(0xFF433D3D),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('corrections')
            .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma solicitação encontrada.',
                style: TextStyle(color: Color(0xFFF4F4F4)),
              ),
            );
          }

          final requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final motivo = request['reason'] ?? 'Motivo não informado';

              // Verifica o tipo do campo 'data' e converte se necessário
              DateTime dataHora;
              if (request['date'] is Timestamp) {
                dataHora = (request['date'] as Timestamp).toDate();
              } else if (request['date'] is String) {
                dataHora = DateTime.parse(request['date']);
              } else {
                dataHora = DateTime.now(); // Valor padrão em caso de erro
              }

              final dataFormatada = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(dataHora);
              final horaFormatada = DateFormat('HH:mm').format(dataHora);

              return ListTile(
                title: Text(
                  motivo,
                  style: const TextStyle(color: Color(0xFFF4F4F4)),
                ),
                subtitle: Text(
                  '$dataFormatada às $horaFormatada',
                  style: const TextStyle(color: Color(0xFFF4F4F4)),
                ),
                leading: const Icon(Icons.access_time, color: Color(0xFFFF8A50)),
              );
            },
          );
        },
      ),
    );
  }
}
