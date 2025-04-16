
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/printer_send_usecase.dart';

part 'printersend_event.dart';
part 'printersend_state.dart';

class PrintersendBloc extends Bloc<PrintersendEvent, PrintersendState> {
  final PrinterSendUseCase printerSendUseCase;
  PrintersendBloc(this.printerSendUseCase) : super(PrintersendInitial()) {

    on<ChangeToInitial>((event, emit) {
      emit(PrintersendInitial());
    });
    on<SendDataToPrinter>((event, emit) async {
      emit(PrintersendLoading());
      final result = await printerSendUseCase(PrinterSendParams(event.macId, event.message));
      result.fold(
        (failure) => emit(PrintersendError(message: failure.message)),
        (message) => emit(PrintersendLoaded(success: message)),
      );
    });
  }
}
