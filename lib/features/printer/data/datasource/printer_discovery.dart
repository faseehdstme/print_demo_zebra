import 'package:flutter/services.dart';
import 'package:print_demo_zebra/core/constants/app_constants.dart';
import 'package:print_demo_zebra/core/server_exception/server_exception.dart';

abstract interface class PrinterSendDatasource{
  Future<String> connectAndPrint(String macId, String message);
  Future<String> disConnect();
}

class PrinterSendDatasourceImpl implements PrinterSendDatasource{
  @override
  Future<String> connectAndPrint(String macId, String message)async {
    try {
      print(message);
      final result = await AppConstants.channel.invokeMethod('printQrImage', {
        'macAddress': macId,
        'qrCode': message,
      });

      if(result == 'success'){
        return result;
      }else{
        throw ServerException('Error in printing');
      }
    }
    on ServerException catch (e) {
      throw ServerException(e.message);
    }
    catch(e){
      print(e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> disConnect() async{
    try{
      final result = await AppConstants.channel.invokeMethod('disConnect');
      return result;
    }
    catch(e){
      throw ServerException(e.toString());
    }
  }

}