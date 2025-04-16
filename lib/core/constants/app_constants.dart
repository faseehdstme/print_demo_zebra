import 'package:flutter/services.dart';

class AppConstants {
  static const MethodChannel channel =
      MethodChannel('com.example.print_demo_zebra/zebra');
  static const String APP_NAME = 'Barcode Duplicating';
  //db
  static const String dbName = 'licencing.db';
  static const int dbVersion = 1;
  static const String tableAuth = 'authentication';
  //image
  //
  static const String logo = 'assets/logo.png';
}
