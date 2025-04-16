import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:print_demo_zebra/core/constants/app_constants.dart';
import 'package:print_demo_zebra/core/failure/failure.dart';
import 'package:print_demo_zebra/core/server_exception/server_exception.dart';

abstract interface class ZebraPrinterService{
  Future <List<String>> getBluetoothPrinters();
  Future<String> connectPrinter(String macId);
}
class ZebraPrinterServiceImpl implements ZebraPrinterService{
  @override
  Future<List<String>> getBluetoothPrinters() async{
    try{
      List data = await AppConstants.channel.invokeMethod('discoverPrinters');
      List<String> result = data.map((e)=>e.toString()).toList();
      return result;
    }
    catch(e){
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> connectPrinter(String macId) async{
   try{
     final result = await AppConstants.channel.invokeMethod('createConnect', {
       'macAddress': macId
     });
     return result;
   }
   catch(e){
     throw ServerException(e.toString());
   }
  }



}
