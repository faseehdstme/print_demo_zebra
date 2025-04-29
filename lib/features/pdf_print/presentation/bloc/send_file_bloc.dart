import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'send_file_event.dart';
part 'send_file_state.dart';

class SendFileBloc extends Bloc<SendFileEvent, SendFileState> {
  SendFileBloc() : super(SendFileInitial()) {
    on<SendFileEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
