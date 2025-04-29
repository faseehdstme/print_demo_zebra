import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_demo_zebra/config/route/app_route.dart';
import 'package:print_demo_zebra/core/server_exception/server_exception.dart';
import 'package:print_demo_zebra/core/utils/widgets/app_text_form_field.dart';
import 'package:print_demo_zebra/features/printer/presentation/bloc/printersend_bloc.dart';
import 'package:print_demo_zebra/features/select_pdf_screen.dart';
import 'package:print_demo_zebra/init_dependencies.dart';

import '../../../../core/utils/widgets/loader.dart';
import '../../../../core/utils/widgets/show_snack.dart';
import '../../data/datasource/printer_discovery.dart';

class PrinterScreen extends StatefulWidget {
  String macId;
  PrinterScreen({super.key,required this.macId});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();
   Future<bool> disConnectPrinter()async {
     try {
       final result = await serviceLocator<PrinterSendDatasource>()
           .disConnect();
       if (result == 'success'){
         return true;
       }
       else{
          return false;
       }
     }
     on ServerException catch (e) {
       return false;
     }
     catch(e){
       return false;
     }
   }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
         if (didPop) return;

         bool isDisconnected = false;

         if (!isDisconnected) {
           showAppSnackBar(context, 'Please wait while disconnecting from printer');
           isDisconnected = await disConnectPrinter();
         }
         if (isDisconnected) {
           Navigator.of(context).pop(); // Allow back navigation after disconnecting
         }
     },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Printer'),
          actions: [
            IconButton(icon: Icon(Icons.picture_as_pdf),onPressed: (){
              Navigator.pushNamed(context, AppRoute.pdfPrint);
            },)
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: BlocConsumer<PrintersendBloc, PrintersendState>(
        listener: (context, printerState) {
      if(printerState is PrintersendError){
        controller.text="";
        _focusNode.requestFocus();
        showAppSnackBar(context, printerState.message);
      }
      else if (printerState is PrintersendLoaded){
        _focusNode.requestFocus();
        controller.text="";
        showAppSnackBar(context, "Data sent to printer successfully");
      }

        },
        builder: (context, printerState) {
      if(printerState is PrintersendLoading){
        return const Center(child: Loader());
      }
      return Column(
            spacing: 20,
            children:  <Widget>[
              AppTextFormField(
                focusNode: _focusNode,
                controller: controller,
                onChange: (value) {
                  print(value);
                  return null;
                },
                onSubmit: (value) {
                    context.read<PrintersendBloc>().add(SendDataToPrinter(macId:widget.macId, message :controller.text));
                    return null;
                },
                label: 'Print Text', labelStyle: Theme.of(context).textTheme.labelSmall!,
              ),

            ],
          );
        },
      ),
        )
      ),
    );
  }
}
