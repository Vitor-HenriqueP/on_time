import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  bool isMatriculaLogin = false; // Controle do switch entre Matrícula e Email/Senha

  // Função para fazer login com email e senha
  Future<void> signInWithEmail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
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

  // Função para fazer login com matrícula
  Future<void> signInWithMatricula() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String matricula = matriculaController.text.trim();

    if (matricula.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, insira a matrícula';
      });
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Verificar se a matrícula existe no Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('matricula', isEqualTo: matricula)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'Matrícula não encontrada';
        });
      } else {
        // Login bem-sucedido com matrícula
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao fazer login com matrícula. Tente novamente mais tarde.';
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

              // Row para o switch e o texto "Login com Matrícula"
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Login com Matrícula',
                    style: TextStyle(
                      color: Color(0xFFF4F4F4),
                      fontSize: 16,
                    ),
                  ),
                  Switch(
                    value: isMatriculaLogin,
                    onChanged: (value) {
                      setState(() {
                        isMatriculaLogin = value;
                      });
                    },
                    activeColor: const Color(0xFFFF8A50),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mostrar campo de matrícula se o switch estiver ativado
              if (isMatriculaLogin) ...[
                // Campo de Matrícula
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Matrícula',
                    style: TextStyle(
                      color: Color(0xFFF4F4F4),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: matriculaController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              // Caso contrário, mostrar campos de E-mail e Senha
              if (!isMatriculaLogin) ...[
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
              ],
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
                  : Column(
                      children: [
                        // Botão de login com matrícula
                        if (isMatriculaLogin) ...[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8A50),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: signInWithMatricula,
                            child: const Text(
                              'ENTRAR COM MATRÍCULA',
                              style: TextStyle(
                                color: Color(0xFFF4F4F4),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                        // Botão de login com email e senha
                        if (!isMatriculaLogin) ...[
                          ElevatedButton(
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
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
