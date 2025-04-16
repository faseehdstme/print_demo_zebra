part of 'connection_bloc.dart';


class ConnectionEvent {}

class GetBluetoothPrinters extends ConnectionEvent {}

class ConnectPrinter extends ConnectionEvent {
  final String macId;
  ConnectPrinter(this.macId);
}
class GetLoadedState extends ConnectionEvent {}