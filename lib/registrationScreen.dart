import 'dart:math'; // Importando o pacote para gerar números aleatórios
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _cpfController = TextEditingController();
  final _nameController = TextEditingController();

  // Função para gerar matrícula com 9 dígitos numéricos
  String generateMatricula() {
    Random random = Random();
    int matricula = 100000000 + random.nextInt(900000000); // Gera um número aleatório de 9 dígitos
    return matricula.toString();
  }

  // Função para registrar o usuário no Firestore
  Future<void> registerUser() async {
    String cpf = _cpfController.text.trim();
    String name = _nameController.text.trim();

    if (cpf.isEmpty || name.isEmpty) {
      // Exibir mensagem de erro se algum campo estiver vazio
      return;
    }

    try {
      // Gerar matrícula automática com 9 dígitos
      String matricula = generateMatricula();

      // Adicionar o usuário no Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'cpf': cpf,
        'name': name,
        'matricula': matricula,
      });

      // Exibir mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuário registrado com sucesso!')));

      // Limpar os campos após o registro
      _cpfController.clear();
      _nameController.clear();
    } catch (e) {
      // Exibir erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registrar usuário: $e')));
    }
  }

  // Função para carregar os usuários do Firestore
  Stream<QuerySnapshot> getUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro de Usuário")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de CPF
            TextField(
              controller: _cpfController,
              decoration: InputDecoration(labelText: 'CPF'),
              keyboardType: TextInputType.number,
            ),
            // Campo de Nome
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 20),
            // Botão de Registro
            ElevatedButton(
              onPressed: registerUser,
              child: Text('Registrar'),
            ),
            SizedBox(height: 20),
            // Lista de Usuários Cadastrados
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Nenhum usuário registrado.'));
                  }

                  var users = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return ListTile(
                        title: Text(user['name']),
                        subtitle: Text('CPF: ${user['cpf']}'),
                        trailing: Text('Matrícula: ${user['matricula']}'),
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
