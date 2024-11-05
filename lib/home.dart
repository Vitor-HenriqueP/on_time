import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'comprove.dart'; // Importando a página Comprove

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    // Obtendo o e-mail do usuário autenticado no Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  // Função que cria um Stream de data/hora atualizada a cada segundo
  Stream<String> getTimeStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield DateFormat('HH:mm:ss').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF433D3D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF433D3D),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Text(
              'Olá, ${userEmail ?? 'Usuário'}',
              style: const TextStyle(color: Color(0xFFF4F4F4), fontSize: 16),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFFF8A50)),
            onPressed: () {
              // Ação para abrir o menu
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo do aplicativo
            Image.asset(
              'assets/img/logo-ontime.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            // Exibindo a hora atual em tempo real
            Center(
              child: Column(
                children: [
                  StreamBuilder<String>(
                    stream: getTimeStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text(
                          'Carregando...',
                          style: TextStyle(
                            fontSize: 48,
                            color: Color(0xFFF4F4F4),
                          ),
                        );
                      }
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                          fontSize: 48,
                          color: Color(0xFFF4F4F4),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFFF4F4F4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Botão de registro
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A50),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () async {
                // Função para registrar horário
                await FirebaseFirestore.instance.collection('ponto').add({
                  'hora': Timestamp.now(),
                });
              },
              child: const Text(
                'Registrar',
                style: TextStyle(color: Color(0xFFF4F4F4), fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            // Botão para ir para Comprove
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A50),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                // Navegar para a página Comprove
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ComproveScreen()),
                );
              },
              child: const Text(
                'Ir para Comprove',
                style: TextStyle(color: Color(0xFFF4F4F4), fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            // Lista dos últimos registros
            const Text(
              'Últimos registros',
              style: TextStyle(fontSize: 20, color: Color(0xFFF4F4F4)),
            ),
            const SizedBox(height: 10),
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
                  return ListView.builder(
                    itemCount: registros.length,
                    itemBuilder: (context, index) {
                      final registro = registros[index];
                      final timestamp = registro['hora'] as Timestamp;
                      final hora = DateFormat('HH:mm').format(timestamp.toDate());
                      final dia = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(timestamp.toDate());

                      return ListTile(
                        leading: const Icon(Icons.access_time, color: Color(0xFFFF8A50)),
                        title: Text(
                          hora,
                          style: const TextStyle(color: Color(0xFFF4F4F4)),
                        ),
                        subtitle: Text(
                          dia,
                          style: const TextStyle(color: Color(0xFFF4F4F4)),
                        ),
                      );
                    },
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