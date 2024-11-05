import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao fazer login. Verifique suas credenciais.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              // Label e Campo de Matrícula
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
              // Label e Campo de Senha
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
                      onPressed: signIn,
                      child: const Text(
                        'ENTRAR',
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
