import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.locationWhenInUse// Added internet permission
    ].request();

    // Handling cases where permissions are denied
    if (statuses[Permission.bluetooth]!.isDenied ||
        statuses[Permission.bluetoothScan]!.isDenied ||
        statuses[Permission.bluetoothConnect]!.isDenied  ) { // Check for internet permission
      // Prompt the user to grant permissions again
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,// Request internet permission again
      ].request();
    }

    // Handling cases where permissions are permanently denied
    if (statuses[Permission.bluetooth]!.isPermanentlyDenied ||
        statuses[Permission.bluetoothScan]!.isPermanentlyDenied ||
        statuses[Permission.bluetoothConnect]!.isPermanentlyDenied) { // Check for internet permission
      openAppSettings();
    }
  }
}