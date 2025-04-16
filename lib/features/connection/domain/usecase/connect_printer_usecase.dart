import 'package:fpdart/fpdart.dart';
import 'package:print_demo_zebra/core/usecase/usecase.dart';

import '../../../../core/failure/failure.dart';
import '../repository/connection_repository.dart';

class ConnectPrinterUsecase implements UseCase<String, String> {
  final ConnectionRepository repo;
  ConnectPrinterUsecase(this.repo);
  @override
  Future<Either<Failure,String>> call(String params)async {
    return await repo.connectPrinter(params);
  }
}