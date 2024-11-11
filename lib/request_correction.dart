import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CorrectionScreen extends StatefulWidget {
  const CorrectionScreen({super.key});

  @override
  _CorrectionScreenState createState() => _CorrectionScreenState();
}

class _CorrectionScreenState extends State<CorrectionScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isLoading = false;
  final String staticMatricula = '12345678'; // Matrícula estática

  @override
  void initState() {
    super.initState();
    // Define o e-mail do usuário no controlador de texto ao iniciar a tela
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? ''; // Obtém o e-mail do usuário
    }
  }

 Future<void> submitCorrection() async {
  setState(() {
    isLoading = true;
  });

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('corrections').add({
        'userId': user.uid,
        'email': emailController.text,
        'matricula': staticMatricula,
        'date': selectedDate.toString(),
        'time': selectedTime.format(context),
        'reason': reasonController.text,
        'submittedAt': Timestamp.now(),
        'status': 'pendente', // Adiciona o campo status com valor pendente
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correção enviada com sucesso!')),
      );

      // Limpar os campos após o envio
      reasonController.clear();
      setState(() {
        selectedDate = DateTime.now();
        selectedTime = TimeOfDay.now();
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao enviar correção. Tente novamente.')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF433D3D),
      appBar: AppBar(
        title: const Text('Solicite a correção'),
        backgroundColor: const Color(0xFF433D3D),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'E-mail:',
                style: TextStyle(
                  color: Color(0xFFF4F4F4),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              // Estilo para o campo de e-mail igual ao campo de matrícula
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF555555),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  emailController.text, // Exibe o e-mail estático
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Matrícula:',
                style: TextStyle(
                  color: Color(0xFFF4F4F4),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              // Estilo do campo de matrícula
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF555555),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  staticMatricula,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Data:',
                style: TextStyle(
                  color: Color(0xFFF4F4F4),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF555555),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hora:',
                style: TextStyle(
                  color: Color(0xFFF4F4F4),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF555555),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    selectedTime.format(context),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Motivo:',
                style: TextStyle(
                  color: Color(0xFFF4F4F4),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A50)),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A50),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: submitCorrection,
                        child: const Text(
                          'Concluir',
                          style: TextStyle(
                            color: Color(0xFFF4F4F4),
                            fontSize: 18,
                          ),
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
