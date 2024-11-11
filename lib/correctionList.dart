import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_final/pontoScreen.dart';

class CorrectionListScreen extends StatelessWidget {
  // Função para atualizar o status da solicitação para "aceita"
  Future<void> _aceitarCorrecao(BuildContext context, DocumentReference correctionRef) async {
    try {
      await correctionRef.update({'status': 'aceita'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de correção aceita!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aceitar a solicitação: $e')),
      );
    }
  }

  // Função para atualizar o status da solicitação para "recusada"
  Future<void> _recusarCorrecao(BuildContext context, DocumentReference correctionRef) async {
    try {
      await correctionRef.update({'status': 'recusada'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de correção recusada!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao recusar a solicitação: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Cor de fundo da tela
      appBar: AppBar(
        backgroundColor: Colors.orange, // Cor do AppBar
        title: const Text('Solicitações de Correção'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('corrections').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma solicitação de correção.'));
          }

          final corrections = snapshot.data!.docs;

          return ListView.builder(
            itemCount: corrections.length,
            itemBuilder: (context, index) {
              final correction = corrections[index];
              final data = correction.data() as Map<String, dynamic>;
              final email = data['email'];
              final date = data['date'];
              final time = data['time'];
              final correctionRef = correction.reference; // Referência para o documento da correção
              final status = data.containsKey('status') ? data['status'] : null;

              return ListTile(
                tileColor: Colors.grey[850], // Cor do item na lista
                title: Text('Solicitação de correção: $email', style: TextStyle(color: Colors.white)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data: $date', style: TextStyle(color: Colors.white70)),
                    Text('Hora: $time', style: TextStyle(color: Colors.white70)),
                    if (status != null) Text('Status: $status', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão para ir à tela de visualização dos registros
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PontoScreen(email: email),
                          ),
                        );
                      },
                    ),
                    // Botão "Finalizar" para aceitar a correção
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        // Exibindo o pop-up de confirmação
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Atenção'),
                              content: const Text(
                                  'Antes de aceitar, verifique se ajustou os registros.'),
                              actions: <Widget>[
                                // Botão para fechar o pop-up
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Fechar'),
                                ),
                                // Botão de confirmação para aceitar
                                TextButton(
                                  onPressed: () {
                                    _aceitarCorrecao(context, correctionRef);
                                    Navigator.of(context).pop(); // Fechar o pop-up
                                  },
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    // Botão "Recusar" para recusar a correção
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        // Exibindo o pop-up de confirmação
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Atenção'),
                              content: const Text(
                                  'Tem certeza que deseja recusar esta solicitação?'),
                              actions: <Widget>[
                                // Botão para fechar o pop-up
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Fechar'),
                                ),
                                // Botão de confirmação para recusar
                                TextButton(
                                  onPressed: () {
                                    _recusarCorrecao(context, correctionRef);
                                    Navigator.of(context).pop(); // Fechar o pop-up
                                  },
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
