import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class StudentBleService {
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Future<void> startScan({
    required Function(String detectedUuid) onDetected,
  }) async {
    if (_isScanning) return;
    _isScanning = true;

    await FlutterBluePlus.startScan();

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final serviceUuids = result.advertisementData.serviceUuids;

        if (serviceUuids.isNotEmpty) {
          final detectedGuid = serviceUuids.first;
          onDetected(detectedGuid.toString());

        }
      }
    });
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;

    await _scanSubscription?.cancel();
    await FlutterBluePlus.stopScan();

    _scanSubscription = null;
    _isScanning = false;
  }

  Future<void> dispose() async {
    await stopScan(); // ✅ qui sì
  }
}
