part of 'printersend_bloc.dart';


 class PrintersendEvent {}

class SendDataToPrinter extends PrintersendEvent {
  final String macId;
  final String message;

  SendDataToPrinter({required this.macId, required this.message});
}
class ChangeToInitial extends PrintersendEvent {}
