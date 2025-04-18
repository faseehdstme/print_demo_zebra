import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';
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
    });
    on<GetBluetoothPrinters>((event, emit) async{
      emit(ConnectionLoading());

       final data = await conUsecase(NoParams());
        data.fold((l)=>emit(ConnectionError(l.message)), (r) {
          preloadedPrinters = r;
          emit(ConnectionLoaded(r));
        });
    });
    on<GetNfcPrinter>((event,emit) async{
      emit(NfcConnectionInitial());
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
         emit(NfcConnectionError(message: "NFC is not available on this device"));
      }

      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        String macAddress = extractMacFromZebraNfcPayload(tag.data['ndef']['cachedMessage']['records'][0]['payload']);
        NfcManager.instance.stopSession();

        add(ConnectPrinter(macAddress));
        // emit(ConnectionInitial());
      });
    });
    on<ConnectPrinter>((event, emit) async{
      emit(ConnectionLoading());
      final data = await conPrinter(event.macId);
      data.fold((l)=>emit(PrinterConnectionError(l.message)), (r)=>emit(PrinterConnectionLoaded(r,event.macId)));
    });
    on<GetLoadedState>((event, emit) {
      emit(ConnectionLoaded(preloadedPrinters));
    });
    on<GetInitialState>((event, emit) {
      emit(ConnectionInitial());
    });
  }

  String extractMacFromZebraNfcPayload(List<int> payload) {
    final url = String.fromCharCodes(payload.sublist(1));
    final uri = Uri.parse("http://$url");
    print(uri);
    final rawMac = uri.queryParameters['mB'];
    if (rawMac == null || rawMac.length != 12) return "MAC not found";
    return formatMac(rawMac);
  }

  String formatMac(String raw) {
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i += 2) {
      if (i > 0) buffer.write(":");
      buffer.write(raw.substring(i, i + 2));
    }
    return buffer.toString().toUpperCase();
  }

}
