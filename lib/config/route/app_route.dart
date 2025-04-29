import 'package:flutter/cupertino.dart';
import 'package:print_demo_zebra/features/connection/presentation/view/connection_screen.dart';
import 'package:print_demo_zebra/features/printer/presentation/view/printer_screen.dart';
import 'package:print_demo_zebra/features/select_pdf_screen.dart';

class AppRoute{
  AppRoute._();
  static const String connection = "/connection";
  static const String print = "/print";
  static const String pdfPrint = "/pdfPrint";

  static final dynamic routes = <String,WidgetBuilder>{
    "/": (BuildContext context) => ConnectionScreen(),
    "/connection": (BuildContext context) => ConnectionScreen(),
    "/print" : (BuildContext context) {
      final args = ModalRoute.of(context)?.settings.arguments as String;
      return PrinterScreen(macId: args);
    },
    "/pdfPrint":(BuildContext context)=>PDFPickerPage()
  };
}