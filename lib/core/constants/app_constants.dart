import 'package:flutter/services.dart';

class AppConstants {
  static const MethodChannel channel =
      MethodChannel('com.example.print_demo_zebra/zebra');
  static const String APP_NAME = 'Barcode Duplicating';
  static const String nfcImage = "assets/nfc.png";
  static const String printerInit = "assets/printer_init.png";
  //db
  static const String dbName = 'licencing.db';
  static const int dbVersion = 1;
  static const String tableAuth = 'authentication';
  //image
  //
  static const String logo = 'assets/logo.png';
}
