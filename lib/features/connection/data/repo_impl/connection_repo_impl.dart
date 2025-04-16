import 'package:fpdart/src/either.dart';
import 'package:print_demo_zebra/core/failure/failure.dart';
import 'package:print_demo_zebra/core/server_exception/server_exception.dart';
import 'package:print_demo_zebra/features/connection/domain/repository/connection_repository.dart';

import '../data_source/zebra_printer.dart';

class ConnectionRepoImpl implements ConnectionRepository{
  ZebraPrinterService connectionDataSource;
  ConnectionRepoImpl(this.connectionDataSource);

  @override
  Future<Either<Failure, List<String>>> getBluetoothPrinters()async {
    try{
      final result = await connectionDataSource.getBluetoothPrinters();
      return Right(result);
    }
    on ServerException catch(e){
      return Left(Failure(message: e.message));
    }
    catch(e){
      return Left(Failure( message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> connectPrinter(String macId) async{
    try{
      final result = await connectionDataSource.connectPrinter(macId);
      return Right(result);
    }
    on ServerException catch(e){
      return Left(Failure(message: e.message));
    }
    catch(e){
      return Left(Failure( message: e.toString()));
    }
  }
}