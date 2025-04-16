part of 'printersend_bloc.dart';

 class PrintersendState {}

 class PrintersendInitial extends PrintersendState {}
class PrintersendLoading extends PrintersendState {}
class PrintersendLoaded extends PrintersendState {
  final String success;
  PrintersendLoaded({required this.success});
}
class PrintersendError extends PrintersendState {
  final String message;
  PrintersendError({required this.message});
}
