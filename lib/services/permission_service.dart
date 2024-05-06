import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  static Future<PermissionStatus> requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      return sdkInt >= 30
          ? Permission.photos.request()
          : Permission.storage.request();
    } else if (Platform.isIOS) {
      return Permission.photos.request();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
