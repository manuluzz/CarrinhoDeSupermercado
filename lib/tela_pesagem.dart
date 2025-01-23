import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Conexão BLE com ESP32'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _readCharacteristic;
  String _receivedData = "Nenhum dado recebido.";
  bool _isScanning = false;

  void _startScan() async {
  setState(() {
    _isScanning = true;
  });

  try {
    final scanResults = await flutterBlue.startScan(timeout: const Duration(seconds: 5));
    for (var scanResult in scanResults) {
      if (scanResult.device.name == "BalancaESP32") {
        await flutterBlue.stopScan();
        _connectToDevice(scanResult.device);
        break;
      }
    }
  } finally {
    setState(() {
      _isScanning = false;
    });
  }
}

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        _connectedDevice = device;
      });

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.read) {
            _readCharacteristic = characteristic;
            _readData();
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Conectado ao ESP32 com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao conectar: $e")),
      );
    }
  }

  Future<void> _readData() async {
    if (_readCharacteristic != null) {
      _readCharacteristic?.value.listen((value) {
        setState(() {
          _receivedData = String.fromCharCodes(value).trim();
        });
      });
    }
  }

  void _disconnectFromDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      setState(() {
        _connectedDevice = null;
        _readCharacteristic = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Desconectado do dispositivo.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Status: ${_connectedDevice != null ? "Conectado" : "Desconectado"}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Peso Recebido:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _receivedData,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.blueAccent,
                  ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _connectedDevice == null ? _startScan : null,
              child: Text(_isScanning ? 'Procurando...' : 'Conectar ao ESP32'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectedDevice != null ? _disconnectFromDevice : null,
              child: const Text('Desconectar'),
            ),
          ],
        ),
      ),
    );
  }
}