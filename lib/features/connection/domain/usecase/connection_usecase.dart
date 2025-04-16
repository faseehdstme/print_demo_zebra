import 'package:fpdart/src/either.dart';
import 'package:print_demo_zebra/core/failure/failure.dart';
import 'package:print_demo_zebra/core/usecase/usecase.dart';
import 'package:print_demo_zebra/features/connection/domain/repository/connection_repository.dart';

class ConnectionUsecase implements UseCase<List<String>,NoParams>{
  final ConnectionRepository repo;
  ConnectionUsecase(this.repo);
  @override
  Future<Either<Failure,List<String>>> call(NoParams params)async {
    return await repo.getBluetoothPrinters();
  }

}