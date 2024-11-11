import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserRecordsScreen extends StatelessWidget {
  final String userEmail;

  UserRecordsScreen({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registros de $userEmail'),
        backgroundColor: Color(0xFF433D3D),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ponto')
            .where('email', isEqualTo: userEmail)
            .orderBy('hora', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhum registro encontrado para $userEmail.',
                style: TextStyle(color: Color(0xFFF4F4F4)),
              ),
            );
          }

          final registros = snapshot.data!.docs;

          return ListView.builder(
            itemCount: registros.length,
            itemBuilder: (context, index) {
              final registro = registros[index];
              final hora = (registro['hora'] as Timestamp).toDate();

              return ListTile(
                title: Text(
                  'Hora: ${DateFormat('HH:mm:ss').format(hora)}',
                  style: TextStyle(color: Color(0xFFF4F4F4)),
                ),
                subtitle: Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(hora)}',
                  style: TextStyle(color: Color(0xFFF4F4F4)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
