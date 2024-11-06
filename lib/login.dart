import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  // Função para fazer login com email e senha
  Future<void> signInWithEmail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Verificar se a senha é a padrão (12345678)
      if (passwordController.text.trim() == '12345678') {
        // Mostrar popup de redefinir senha
        _showResetPasswordDialog();
      } else {
        // Usuário autenticado com sucesso
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao fazer login com email e senha. Verifique suas credenciais.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para exibir o popup de redefinir senha
  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Redefinir Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No primeiro acesso, você precisa redefinir sua senha.'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Atualiza a senha do usuário no Firebase
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.updatePassword(passwordController.text.trim());
                    Navigator.of(context).pop(); // Fecha o popup
                    Navigator.pushReplacementNamed(context, '/home'); // Redireciona para a tela inicial
                  }
                } catch (e) {
                  print('Erro ao redefinir a senha: $e');
                }
              },
              child: const Text('Redefinir'),
            ),
          ],
        );
      },
    );
  }

  // Função para verificar a sessão do usuário ao iniciar o app
  Future<void> checkUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      // Usuário está logado, redireciona para a tela inicial
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserSession(); // Verifica a sessão do usuário ao iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF433D3D),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img/logo-ontime.png',
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'OnTime',
                style: TextStyle(
                  fontSize: 32,
                  color: Color(0xFFF4F4F4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Campo de E-mail
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'E-mail',
                  style: TextStyle(
                    color: Color(0xFFF4F4F4),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Campo de Senha
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Senha',
                  style: TextStyle(
                    color: Color(0xFFF4F4F4),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A50)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A50),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: signInWithEmail,
                      child: const Text(
                        'ENTRAR COM E-MAIL',
                        style: TextStyle(
                          color: Color(0xFFF4F4F4),
                          fontSize: 18,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
