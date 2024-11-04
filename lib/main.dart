import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login.dart'; // Importando a tela de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

   await initializeDateFormatting('pt_BR', null);
   
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Input',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(), // Define LoginScreen como a tela inicial
      routes: {
        '/home': (context) => const MyHomePage(), // Rota para a tela principal
      },
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Enviar e listar dados do Firestore')),
//       body: Column(
//         children: [
//           Expanded(child: WordList()), // Lista de palavras do Firestore
//           DataInputWidget(), // Input para enviar dados
//         ],
//       ),
//     );
//   }
// }
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFFF4F4F4)),
          onPressed: () {
            // ação para abrir o menu
          },
        ),
        title: const Text(
          'Olá, Vitor!',
          style: TextStyle(color: Color(0xFFF4F4F4)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
class WordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('data').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar dados'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhuma palavra encontrada.'));
        }

        final words = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ListTile(
            title: Text(data['text'] ?? 'Sem texto'),
          );
        }).toList();

        return ListView(children: words);
      },
    );
  }
}

class DataInputWidget extends StatefulWidget {
  @override
  _DataInputWidgetState createState() => _DataInputWidgetState();
}

class _DataInputWidgetState extends State<DataInputWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('data').add({
        'text': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados enviados com sucesso!')),
      );
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar dados: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Digite algo',
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? RotationTransition(
                  turns: _animationController,
                  child: const Icon(Icons.sync, size: 50),
                )
              : ElevatedButton(
                  onPressed: _sendData,
                  child: const Text('Enviar'),
                ),
        ],
      ),
    );
  }
}
