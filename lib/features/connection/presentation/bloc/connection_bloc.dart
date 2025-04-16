import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_demo_zebra/core/usecase/usecase.dart';
import 'package:print_demo_zebra/features/connection/domain/usecase/connect_printer_usecase.dart';
import 'package:print_demo_zebra/features/connection/domain/usecase/connection_usecase.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionBlocState> {
  final ConnectionUsecase conUsecase;
  final ConnectPrinterUsecase conPrinter;
  List<String> preloadedPrinters = [];
  ConnectionBloc({required this.conUsecase,required this.conPrinter}) : super(ConnectionInitial()) {
    on<ConnectionEvent>((event, emit) {
      emit(ConnectionLoading());
    });
    on<GetBluetoothPrinters>((event, emit) async{
       final data = await conUsecase(NoParams());
        data.fold((l)=>emit(ConnectionError(l.message)), (r) {
          preloadedPrinters = r;
          emit(ConnectionLoaded(r));
        });
    });
    on<ConnectPrinter>((event, emit) async{
      final data = await conPrinter(event.macId);
      data.fold((l)=>emit(PrinterConnectionError(l.message)), (r)=>emit(PrinterConnectionLoaded(r,event.macId)));
    });
    on<GetLoadedState>((event, emit) {
      emit(ConnectionLoaded(preloadedPrinters));
    });
  }
}
