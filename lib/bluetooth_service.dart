import 'package:flutter_blue/flutter_blue.dart';

class MyBluetoothService {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _readCharacteristic;

  bool get isConnected => _connectedDevice != null;

  Function(String)? onDataReceived;

  Future<void> scanAndConnect() async {
    try {
      final scanResults = await _flutterBlue.startScan(timeout: const Duration(seconds: 5));
      for (var scanResult in scanResults) {
        if (scanResult.device.name == "BalancaESP32") {
          await _flutterBlue.stopScan();
          await _connectToDevice(scanResult.device);
          break;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;

      List<BluetoothService> services = await device.discoverServices(); // Resolve o tipo
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.read) {
            _readCharacteristic = characteristic;
            _readData();
          }
        }
      }
    } catch (e) {
      disconnect();
      rethrow;
    }
  }

  void _readData() {
    _readCharacteristic?.value.listen((value) {
      final data = String.fromCharCodes(value).trim();
      if (onDataReceived != null) {
        onDataReceived!(data);
      }
    });
  }

  void disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _readCharacteristic = null;
    }
  }
}
