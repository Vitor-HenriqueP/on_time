import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  // Função para excluir a solicitação do Firestore
  Future<void> _deleteRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('corrections')
          .doc(requestId)
          .delete();
    } catch (e) {
      print('Erro ao excluir solicitação: $e');
    }
  }

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

              // Obtendo o status da solicitação
              final status = request['status'] ?? 'Status não informado';

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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dataFormatada às $horaFormatada',
                      style: const TextStyle(color: Color(0xFFF4F4F4)),
                    ),
                    Text(
                      'Status: $status',
                      style: const TextStyle(color: Color(0xFFF4F4F4), fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                leading: const Icon(Icons.access_time, color: Color(0xFFFF8A50)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFFF8A50)),
                  onPressed: () {
                    // Confirma a exclusão antes de proceder
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Excluir Solicitação'),
                        content: const Text('Você tem certeza que deseja excluir esta solicitação?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteRequest(request.id);  // Exclui a solicitação
                              Navigator.of(context).pop();
                            },
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
