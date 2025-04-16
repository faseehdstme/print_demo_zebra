import 'package:fpdart/fpdart.dart';
import 'package:print_demo_zebra/core/usecase/usecase.dart';

import '../../../../core/failure/failure.dart';
import '../repository/printer_send_repository.dart';

class PrinterSendUseCase implements UseCase<String, PrinterSendParams> {
  final PrinterSendRepository printerSendRepository;

  PrinterSendUseCase(this.printerSendRepository);

  @override
  Future<Either<Failure, String>> call(PrinterSendParams params) async {
    return await printerSendRepository.connectAndPrint(params.macId, params.message);
  }
}

class PrinterSendParams {
  final String macId;
  final String message;

  PrinterSendParams(this.macId, this.message);
}