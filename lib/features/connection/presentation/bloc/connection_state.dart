part of 'connection_bloc.dart';

class ConnectionBlocState {}

class ConnectionInitial extends ConnectionBlocState {}
class ConnectionLoaded extends ConnectionBlocState {
  final List<String> printers;
  ConnectionLoaded(this.printers);
}
class ConnectionLoading extends ConnectionBlocState {}
class ConnectionError extends ConnectionBlocState {
  final String message;
  ConnectionError(this.message);
}

class PrinterConnectionLoaded extends ConnectionBlocState {
  final String printers;
  final String connectedPrinter;
  PrinterConnectionLoaded(this.printers, this.connectedPrinter);
}
class PrinterConnectionLoading extends ConnectionBlocState {}
class PrinterConnectionError extends ConnectionBlocState {
  final String message;
  PrinterConnectionError(this.message);
}

class NfcConnectionInitial extends ConnectionBlocState{}
class NfcConnectionError extends ConnectionBlocState{
  final String message;
  NfcConnectionError({required this.message});
}

