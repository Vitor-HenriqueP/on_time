import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'comprove.dart';
import 'request_correction.dart';
import 'requests_screens.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? userEmail;
  bool hasRequests = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _checkUserRequests();
  }

  Future<void> _loadUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  Future<void> _checkUserRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('corrections')
          .where('email', isEqualTo: user.email)
          .limit(1) // Limitando a 1 para otimizar a consulta
          .get();

      setState(() {
        hasRequests = querySnapshot.docs.isNotEmpty;
      });
    }
  }

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
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFFFF8A50)),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
  backgroundColor: const Color(0xFF433D3D),
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: const BoxDecoration(color: Color(0xFF433D3D)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFF8A50),
              radius: 24,
              child: Icon(Icons.close, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Image.asset(
              'assets/img/logo-ontime.png',
              height: 50,
            ),
          ],
        ),
      ),
      ListTile(
        title: const Text('Consultar Histórico', style: TextStyle(color: Color(0xFFF4F4F4))),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ComproveScreen()),
          );
        },
      ),
      ListTile(
        title: const Text('Solicitar Correção', style: TextStyle(color: Color(0xFFF4F4F4))),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CorrectionScreen()),
          );
        },
      ),
      if (hasRequests) // Condição para exibir "Minhas Solicitações"
        ListTile(
          title: const Text('Minhas Solicitações', style: TextStyle(color: Color(0xFFF4F4F4))),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyRequestsScreen()),
            );
          },
        ),
    ],
  ),
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/logo-ontime.png',
              height: 100,
            ),
            const SizedBox(height: 20),
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
                    DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
                        .format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFFF4F4F4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A50),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () async {
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A50),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComproveScreen()),
                );
              },
              child: const Text(
                'Meus comprovantes',
                style: TextStyle(color: Color(0xFFF4F4F4), fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
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
                      final hora =
                          DateFormat('HH:mm').format(timestamp.toDate());
                      final dia =
                          DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
                              .format(timestamp.toDate());

                      return ListTile(
                        leading: const Icon(Icons.access_time,
                            color: Color(0xFFFF8A50)),
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
