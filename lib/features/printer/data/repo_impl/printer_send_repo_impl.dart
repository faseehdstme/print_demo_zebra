import 'package:fpdart/fpdart.dart';
import 'package:print_demo_zebra/core/server_exception/server_exception.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/repository/printer_send_repository.dart';
import '../datasource/printer_discovery.dart';

class PrinterSendRepositoryImpl implements PrinterSendRepository {
  final PrinterSendDatasource printerSendDatasource;

  PrinterSendRepositoryImpl(this.printerSendDatasource);

  @override
  Future<Either<Failure,String>> connectAndPrint(String macId, String message) async {
    try {
      final result = await printerSendDatasource.connectAndPrint(macId, message);
      return Right(result);
    }
    on ServerException catch(e){
      return Left(Failure(message: e.message));
    }
    catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> connectPrinter(String macId) {
    // TODO: implement connectPrinter
    throw UnimplementedError();
  }
}