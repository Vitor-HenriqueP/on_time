import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DetalhePontoScreen extends StatefulWidget {
  final QueryDocumentSnapshot registro;

  DetalhePontoScreen({required this.registro});

  @override
  _DetalhePontoScreenState createState() => _DetalhePontoScreenState();
}

class _DetalhePontoScreenState extends State<DetalhePontoScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final timestamp = widget.registro['hora'] as Timestamp;
    _selectedDate = timestamp.toDate();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveChanges() async {
    final DateTime updatedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Atualiza o registro no Firestore
    await widget.registro.reference.update({
      'hora': Timestamp.fromDate(updatedDateTime),
      'status': 'aceita', // Define o status como "aceita" ao salvar as alterações
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro atualizado com sucesso!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],  // Cor de fundo da AppBar
        title: const Text(
          'Detalhes do Registro de Ponto',
          style: TextStyle(color: Colors.orange),  // Cor do título da AppBar
        ),
      ),
      backgroundColor: Colors.grey[900],  // Cor de fundo da tela
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hora: ${DateFormat('HH:mm:ss').format(_selectedDate)}',
              style: const TextStyle(fontSize: 18, color: Colors.orange),  // Cor do texto
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              style: const TextStyle(fontSize: 18, color: Colors.orange),  // Cor do texto
            ),
            const SizedBox(height: 8),
            Text(
              'Usuário: ${widget.registro['email']}',
              style: const TextStyle(fontSize: 18, color: Colors.orange),  // Cor do texto
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,  // Cor de fundo dos botões
              ),
              onPressed: _pickDate,
              child: const Text('Editar Data', style: TextStyle(color: Colors.black)),  // Cor do texto do botão
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,  // Cor de fundo dos botões
              ),
              onPressed: _pickTime,
              child: const Text('Editar Hora', style: TextStyle(color: Colors.black)),  // Cor do texto do botão
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,  // Cor de fundo dos botões
              ),
              onPressed: _saveChanges,
              child: const Text('Salvar Alterações', style: TextStyle(color: Colors.black)),  // Cor do texto do botão
            ),
          ],
        ),
      ),
    );
  }
}
