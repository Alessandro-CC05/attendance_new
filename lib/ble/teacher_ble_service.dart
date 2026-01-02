import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class TeacherBleService {
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();

  Future<void> startAdvertising(String sessionUuid) async {
    final advertiseData = AdvertiseData(
      includeDeviceName: false,
      serviceUuid: sessionUuid,
    );

    await _blePeripheral.start(advertiseData: advertiseData);
  }

  Future<void> stopAdvertising() async {
    await _blePeripheral.stop();
  }
}
