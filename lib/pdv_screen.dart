// pdv_screen.dart
import 'package:flutter/material.dart';

class PDVScreen extends StatefulWidget {
  const PDVScreen({Key? key}) : super(key: key);

  @override
  State<PDVScreen> createState() => _PDVScreenState();
}

class _PDVScreenState extends State<PDVScreen> {
  final List<Map<String, dynamic>> _products = [];

  void _scanProduct() {
    // Abre um pop-up para inserir o código de barras
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDV - Caixa'),
        backgroundColor: Colors.green,
      ),
      body: Row(
        children: [
          // Menu lateral fixo
          Container(
            width: 250,
            color: Colors.green[50],
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.green),
                  child: Text(
                    'Menu PDV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Finalizar Compra'),
                  onTap: _finalizePurchase,
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: const Text('Escanear Produto'),
                  onTap: _scanProduct,
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
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'R\$ ${_products.fold<double>(0.0, (total, product) => total + product['price']).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
    );
  }
}
