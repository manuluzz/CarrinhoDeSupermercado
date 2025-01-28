import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssistenteScreen extends StatefulWidget {
  const AssistenteScreen({Key? key}) : super(key: key);

  @override
  State<AssistenteScreen> createState() => _AssistenteScreenState();
}

class _AssistenteScreenState extends State<AssistenteScreen> {
  final TextEditingController _questionController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  final String _apiKey = 'AIzaSyDIvtbbNCCx4iV0Dparf4qlDxpXnGFBDH8'; // Substitua pela sua chave da API do Google AI Studio
  final String _endpoint = 'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText';

  Future<void> _getAnswer() async {
    String query = _questionController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _result = "Por favor, insira uma pergunta ou busca.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Construção do corpo da requisição
      final body = jsonEncode({
        'prompt': {
          'text': query,
        },
        'temperature': 0.7,  // Ajuste da criatividade
        'topP': 1.0,         // Alternativa para temperatura
        'candidateCount': 1, // Quantidade de respostas
      });

      // Enviar requisição POST
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('candidates')) {
          setState(() {
            _result = data['candidates'][0]['output'] ?? "Nenhuma resposta encontrada.";
          });
        } else {
          setState(() {
            _result = "Erro: resposta não encontrada no corpo da API.";
          });
        }
      } else {
        setState(() {
          _result = "Erro ao buscar dados: ${response.statusCode} - ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Erro de conexão: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Inteligente'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Faça uma pergunta ou busca:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Digite sua pergunta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _getAnswer,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : const Text('Buscar Resposta'),
            ),
            const SizedBox(height: 16.0),
            if (_result.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
