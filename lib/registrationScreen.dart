import 'dart:math'; // Importando o pacote para gerar números aleatórios
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _emailController = TextEditingController();

  // Função para gerar matrícula com 9 dígitos numéricos
  String generateMatricula() {
    Random random = Random();
    int matricula = 100000000 + random.nextInt(900000000); // Gera um número aleatório de 9 dígitos
    return matricula.toString();
  }

  // Função para registrar o usuário no Firestore e Firebase Authentication
  Future<void> registerUser() async {
    String cpf = _cpfController.text.trim();
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    if (cpf.isEmpty || name.isEmpty || email.isEmpty) {
      // Exibir mensagem de erro se algum campo estiver vazio
      return;
    }

    try {
      // Criar usuário no Firebase Authentication com email e senha padrão
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: '12345678', // Senha padrão
      );

      // Gerar matrícula automática com 9 dígitos
      String matricula = generateMatricula();

      // Adicionar o usuário no Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'cpf': cpf,
        'name': name,
        'email': email,
        'matricula': matricula,
        'uid': userCredential.user?.uid, // Armazenar o UID do usuário
      });

      // Exibir mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuário registrado com sucesso!')));

      // Limpar os campos após o registro
      _cpfController.clear();
      _nameController.clear();
      _emailController.clear();
    } catch (e) {
      // Exibir erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registrar usuário: $e')));
    }
  }

  // Função para excluir o usuário do Firestore
  Future<void> deleteUser(String userId) async {
    try {
      // Excluir o usuário do Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuário excluído com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir usuário: $e')));
    }
  }

  // Função para carregar os usuários do Firestore
  Stream<QuerySnapshot> getUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro de Usuário", style: TextStyle(color: Colors.white)), // Cor da fonte do AppBar
        backgroundColor: Color(0xFFFF8A50), // Cor do AppBar
      ),
      body: Container(
        color: Color(0xFF433D3D), // Cor de fundo do corpo da tela
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de CPF
            TextField(
              controller: _cpfController,
              decoration: InputDecoration(
                labelText: 'CPF',
                labelStyle: TextStyle(color: Color(0xFFFF8A50)), // Cor do texto da label
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white), // Cor do texto do campo
            ),
            SizedBox(height: 10),
            // Campo de Nome
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(color: Color(0xFFFF8A50)), // Cor do texto da label
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white), // Cor do texto do campo
            ),
            SizedBox(height: 10),
            // Campo de Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFFFF8A50)), // Cor do texto da label
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white), // Cor do texto do campo
            ),
            SizedBox(height: 20),
            // Botão de Registro
            ElevatedButton(
              onPressed: registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8A50), // Cor de fundo do botão
              ),
              child: Text(
                'Registrar',
                style: TextStyle(color: Colors.white), // Cor do texto do botão
              ),
            ),
            SizedBox(height: 20),
            // Lista de Usuários Cadastrados
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A50)))); // Cor do indicador de carregamento
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Nenhum usuário registrado.', style: TextStyle(color: Colors.white))); // Cor do texto
                  }

                  var users = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return ListTile(
                        title: Text(user['name'], style: TextStyle(color: Colors.white)), // Cor do nome do usuário
                        subtitle: Text('CPF: ${user['cpf']}\nEmail: ${user['email']}', style: TextStyle(color: Colors.white)), // Cor do CPF e e-mail
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Matrícula: ${user['matricula']}', style: TextStyle(color: Colors.white)), // Cor da matrícula
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white), // Ícone de exclusão
                              onPressed: () => deleteUser(user.id), // Função de exclusão
                            ),
                          ],
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
