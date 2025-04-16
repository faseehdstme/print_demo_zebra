import 'package:fpdart/fpdart.dart';
import 'package:print_demo_zebra/core/failure/failure.dart';

abstract interface class PrinterSendRepository{
  Future<Either<Failure,String>> connectAndPrint(String macId, String message);
}