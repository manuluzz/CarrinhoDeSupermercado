import 'package:flutter/material.dart';
import 'bluetooth_service.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothScreen> createState() => _MyBluetoothScreenState();
}

class _MyBluetoothScreenState extends State<BluetoothScreen> {
  final MyBluetoothService _bluetoothService = MyBluetoothService();
  String _receivedData = "Nenhum dado recebido.";
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _bluetoothService.onDataReceived = (data) {
      setState(() {
        _receivedData = data;
      });
    };
  }

  @override
  void dispose() {
    _bluetoothService.disconnect();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
    });
    await _bluetoothService.scanAndConnect();
    setState(() {
      _isScanning = false;
    });
  }

  void _disconnect() {
    _bluetoothService.disconnect();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexão BLE com ESP32'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Status: ${_bluetoothService.isConnected ? "Conectado" : "Desconectado"}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Peso Recebido:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _receivedData,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.blueAccent),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: !_bluetoothService.isConnected ? _startScan : null,
              child: Text(_isScanning ? 'Procurando...' : 'Conectar ao ESP32'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bluetoothService.isConnected ? _disconnect : null,
              child: const Text('Desconectar'),
            ),
          ],
        ),
      ),
    );
  }
}
