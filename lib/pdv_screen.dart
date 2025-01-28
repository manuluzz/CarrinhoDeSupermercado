import 'package:flutter/material.dart';
import 'package:carrinhodesupermercado/tela_pesagem.dart';
import 'package:carrinhodesupermercado/assistente_screen.dart';

class PDVScreen extends StatefulWidget {
  final String clientName;

  const PDVScreen({Key? key, required this.clientName}) : super(key: key);

  @override
  State<PDVScreen> createState() => _PDVScreenState();
}

class _PDVScreenState extends State<PDVScreen> {
  final List<Map<String, dynamic>> _products = [];

  Future<bool> _onWillPop() async {
    bool? confirmExit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Encerrar Sessão"),
        content: const Text("Você deseja encerrar a sessão?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Não encerra
            child: const Text("Não"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Encerra
            child: const Text("Sim"),
          ),
        ],
      ),
    );

    if (confirmExit == true) {
      // Limpa os dados antes de sair
      return true; // Permite sair
    }
    return false; // Bloqueia a ação de voltar
  }

  void _scanProduct() { // Abre um pop-up para inserir o código de barras
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController barcodeController = TextEditingController();
        return AlertDialog(
          title: const Text('Escanear Produto'),
          content: TextField(
            controller: barcodeController,
            decoration: const InputDecoration(
              labelText: 'Código de Barras',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o pop-up sem fazer nada
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Simula a leitura do produto usando o código de barras digitado
                setState(() {
                  _products.add({
                    'description': 'Produto Exemplo - Código ${barcodeController.text}',
                    'weight': '1.5 kg',
                    'quantity': 1,
                    'price': 12.99,
                  });
                });
                Navigator.of(context).pop(); // Fecha o pop-up
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _finalizePurchase() {
    // Verifica se há produtos no carrinho antes de finalizar
    if (_products.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Primeiro escaneie algum produto.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Lógica para finalizar a compra
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compra Finalizada'),
        content: const Text('Agradecemos sua compra!'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _products.clear(); // Limpa os produtos após finalizar a compra
              });
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Bem-vindo ao Supermercado Online.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
          ),
          backgroundColor: Colors.blue.shade700,
        ),
        body: Row(
          children: [
            Container(
              width: 250,
              color: Colors.blue.shade100,
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue.shade100),
                    child: Text(
                      'Boas compras, ${widget.clientName}!',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Escanear Produto'),
                    onTap: _scanProduct,
                  ),
                  ListTile(
                    leading: const Icon(Icons.balance),
                    title: const Text('Pesar Produto'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BluetoothScreen()),
                      );
                    },
                  ),
                      ListTile(
                    leading: const Icon(Icons.assistant),
                    title: const Text('Assistente Inteligente'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AssistenteScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('Finalizar Compra'),
                    onTap: _finalizePurchase,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produtos no Carrinho:',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            child: ListTile(
                              title: Text(product['description']),
                              subtitle: Text(
                                'Peso: ${product['weight']} | Quantidade: ${product['quantity']}\nPreço: R\$ ${product['price'].toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _products.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_products.isNotEmpty) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${_products.fold<double>(0.0, (total, product) => total + product['price']).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
