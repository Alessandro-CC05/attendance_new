import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class StudentBleService {
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _subscription;

  Future<void> startScan({
    required void Function(String detectedUuid) onDetected,
  }) async {
    if (_isScanning) return;

    _isScanning = true;

    await FlutterBluePlus.startScan(
      timeout: const Duration(minutes: 5),
    );

    _subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final serviceUuids = r.advertisementData.serviceUuids;

        if (serviceUuids.isEmpty) continue;

        final detectedUuid = serviceUuids.first.toString();

        // 👉 UUID trovato → stop definitivo
        stopScan();
        onDetected(detectedUuid);
        return;
      }
    });
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;

    await _subscription?.cancel();
    await FlutterBluePlus.stopScan();

    _subscription = null;
    _isScanning = false;
  }

  Future<void> dispose() async {
    await stopScan();
  }
}
