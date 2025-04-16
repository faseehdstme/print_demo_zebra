import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';

abstract interface class ConnectionRepository{
  Future<Either<Failure, List<String>>> getBluetoothPrinters();
  Future<Either<Failure,String>> connectPrinter(String macId);
}