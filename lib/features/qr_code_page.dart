import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key, required this.title});
  final String title;

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {

  final GlobalKey qrKey = GlobalKey();
  String _qrText = '';
  final TextEditingController _textController = TextEditingController();
  Future<Uint8List?> capturePng() async {
    try {
      RenderRepaintBoundary boundary =
      qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print(e);
      return null;
    }
  }
  bool showText = false;
  String byteValue="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Enter text for QR code',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (value) {
                    setState(() {
                      _qrText = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (_qrText.isNotEmpty)
                  Column(
                    children: [
                      RepaintBoundary(
                        key: qrKey,
                        child: QrImageView(
                          data: _qrText,
                          version: QrVersions.auto,
                          size: 250,
                          embeddedImage: AssetImage('assets/logo.png'),
                          embeddedImageStyle: const QrEmbeddedImageStyle(
                            size: Size(60, 60),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Uint8List? pngBytes = await capturePng();
                          if (pngBytes != null) {
                            byteValue = pngBytes.toString();
                            setState(() {
                              showText = true;
                            });
                          }
                        },
                        child: Text('Export QR as Bitmap'),
                      ),
                    ],
                  )
                else
                  const Text('QR code will appear here'),
                
                showText==true? Text(byteValue):SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
