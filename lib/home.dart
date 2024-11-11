import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_final/correctionList.dart';
import 'package:intl/intl.dart';
import 'comprove.dart';
import 'login.dart';
import 'request_correction.dart';
import 'requests_screens.dart';

import 'registrationScreen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  String? userEmail;
  bool hasRequests = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _checkUserRequests();
    
    // Inicializa o controller de animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duração da animação
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Libera recursos do controller quando o widget é destruído
    super.dispose();
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
          .limit(1)
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

  // Stream para obter os últimos registros de ponto
  Stream<List<Map<String, dynamic>>> getLastPontoRecords() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('ponto')
          .where('email', isEqualTo: user.email)
          .orderBy('hora', descending: true)
          .limit(5) // Limita para os últimos 5 registros
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {
                    'hora': DateFormat('HH:mm:ss').format(
                        (doc['hora'] as Timestamp).toDate()),
                    'data': DateFormat('dd/MM/yyyy').format(
                        (doc['hora'] as Timestamp).toDate())
                  })
              .toList());
    } else {
      return Stream.value([]);
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
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFFF8A50),
                      radius: 24,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (userEmail == 'teste@teste.com.br')
              ListTile(
                title: const Text(
                  'Cadastrar Usuário',
                  style: TextStyle(color: Color(0xFFF4F4F4)),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
              ),
            if (userEmail == 'teste@teste.com.br')
              ListTile(
                title: const Text(
                  'Solicitações de Correção',
                  style: TextStyle(color: Color(0xFFF4F4F4)),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CorrectionListScreen()),
                  );
                },
              ),
            if (userEmail != 'teste@teste.com.br') ...[
              ListTile(
                title: const Text(
                  'Solicitar Correção',
                  style: TextStyle(color: Color(0xFFF4F4F4)),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CorrectionScreen()),
                  );
                },
              ),
              if (hasRequests)
                ListTile(
                  title: const Text(
                    'Minhas Solicitações',
                    style: TextStyle(color: Color(0xFFF4F4F4)),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyRequestsScreen()),
                    );
                  },
                ),
            ],
            ListTile(
              title: const Text(
                'Logout',
                style: TextStyle(color: Color(0xFFF4F4F4)),
              ),
              leading: const Icon(Icons.exit_to_app, color: Color(0xFFFF8A50)),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } catch (e) {
                  print('Erro ao fazer logout: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao realizar logout')),
                  );
                }
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
            // Condicional para esconder o botão de registrar ponto
            if (userEmail != 'teste@teste.com.br')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A50),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Diminui a largura
                ),
                onPressed: () async {
                  // Anima o ícone (rotação de 180 graus)
                  await _animationController.forward(from: 0);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance.collection('ponto').add({
                      'hora': Timestamp.now(),
                      'email': user.email,
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      child: const Icon(
                        Icons.access_time, // Ícone de relógio
                        color: Color(0xFFF4F4F4),
                      ),
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 2 * 3.14159, // Rotaciona o ícone
                          child: child,
                        );
                      },
                    ),
                    SizedBox(width: 10), // Espaçamento entre o ícone e o texto
                    const Text(
                      'Registrar',
                      style: TextStyle(color: Color(0xFFF4F4F4), fontSize: 18),
                    ),
                  ],
                ),
              ),
                  SizedBox(height: 20), // Espaço entre os botões

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
                'Registros de ponto',
                style: TextStyle(color: Color(0xFFF4F4F4), fontSize: 18),
              ),
            ),
    
            const SizedBox(height: 60),
            // Exibe os últimos registros de ponto
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

                  return ListView.builder(
                    itemCount: filteredRegistros.length,
                    itemBuilder: (context, index) {
                      final registro = filteredRegistros[index];
                      final hora = (registro['hora'] as Timestamp).toDate();
                      final email = registro['email'];

                      return ListTile(
                        title: Text(
                          'Hora: ${DateFormat('HH:mm:ss').format(hora)}',
                          style: const TextStyle(color: Color(0xFFF4F4F4)),
                        ),
                        subtitle: Text(
                          'Email: $email',
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