import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

class PDFPickerPage extends StatefulWidget {
  @override
  _PDFPickerPageState createState() => _PDFPickerPageState();
}

class _PDFPickerPageState extends State<PDFPickerPage> {
  String? fileName;
  String? filePath;
  Uri? pdfFileUri;
  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath1 = result.files.single.path!;
      pdfFileUri = Uri.file(filePath1); // 👈 Get Uri from path

      print("PDF URI: $pdfFileUri");
      setState(() {
        fileName = result.files.single.name;
        filePath = result.files.single.path!;
      });
    } else {
      // User canceled the picker
      print("No file selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick PDF File")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickPDF,
              child: const Text("Pick PDF"),
            ),
            const SizedBox(height: 20),
            if (fileName != null && pdfFileUri!=null) Column(
              children: [
                Text("Selected File: $fileName"),
                ElevatedButton(onPressed: ()async{
                  try{
                    final result = await AppConstants.channel.invokeMethod("pdfPrint", {
                      'fileUri': pdfFileUri.toString()
                    });
                    print(result);
                  }
                  catch(e){
                   print(e.toString());
                  }
                }, child: Text("Print"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}