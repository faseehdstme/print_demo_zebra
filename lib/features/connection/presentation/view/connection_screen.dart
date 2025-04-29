import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_demo_zebra/config/route/app_route.dart';
import 'package:print_demo_zebra/core/color_pellete/app_pellette.dart';
import 'package:print_demo_zebra/core/constants/app_constants.dart';
import 'package:print_demo_zebra/core/utils/message_box.dart';
import 'package:print_demo_zebra/core/utils/widgets/show_snack.dart';
import 'package:print_demo_zebra/features/connection/presentation/bloc/connection_bloc.dart';

import '../../../../core/utils/widgets/app_text.dart';
import '../../../../core/utils/widgets/loader.dart';
import '../../../printer/presentation/view/printer_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  List<Map<String, String>> printers = [];

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Connections'),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth_audio_sharp),
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<ConnectionBloc>().add(GetBluetoothPrinters());
              });
            },
          ),
          IconButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<ConnectionBloc>().add(GetNfcPrinter());
                });
              },
              icon: Icon(Icons.nfc_outlined))
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        height: size.height,
        width: size.width,
        child: RefreshIndicator(
          onRefresh: () async {
            return context.read<ConnectionBloc>().add(GetBluetoothPrinters());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              AppText(
                bodyText: 'Available Printers',
                bodyStyle: Theme.of(context).textTheme.bodyMedium!,
                textSize: 17,
              ),
              Expanded(
                child: BlocConsumer<ConnectionBloc, ConnectionBlocState>(
                    builder: (context, connectionState) {
                  if (connectionState is ConnectionLoaded) {
                    return connectionState.printers.isEmpty
                        ? Center(
                            child: AppText(
                              bodyText: "Printers Not Found",
                              bodyStyle: Theme.of(context).textTheme.bodyMedium!,
                              maxLines: 3,
                              textSize: 17,
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: connectionState.printers.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                  onTap: () async {
                                    context.read<ConnectionBloc>().add(
                                        ConnectPrinter(
                                            connectionState.printers[index]));
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  tileColor: ColorPellete.lightMatGreen,
                                  leading: const Icon(Icons.ads_click),
                                  title: AppText(
                                    bodyText: connectionState.printers[index],
                                    bodyStyle:
                                        Theme.of(context).textTheme.bodyMedium!,
                                    textSize: 15,
                                  ));
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return const SizedBox(
                                height: 10,
                              );
                            },
                          );
                  } else if (connectionState is ConnectionError) {
                    return Center(
                      child: AppText(
                        bodyText: connectionState.message,
                        bodyStyle: Theme.of(context).textTheme.bodyMedium!,
                        maxLines: 3,
                        textSize: 19,
                      ),
                    );
                  } else if (connectionState is ConnectionInitial) {
                    return Center(
                      child: MessageBox(asset: AppConstants.printerInit, message: "Initiate Printer connection"),
                    );
                  } else if (connectionState is NfcConnectionInitial) {
                    return Center(
                      child: MessageBox(
                          asset: AppConstants.nfcImage,
                          message: "Please tap NFC Tag "),
                    );
                  } else {
                    return Center(child: Loader());
                  }
                }, listener: (context, state) {
                  if (state is PrinterConnectionLoaded) {
                    Navigator.pushNamed(
                        context,
                        AppRoute.print,
                    arguments: state.connectedPrinter);
                    Future.delayed(Duration(seconds: 3),(){
                      context.read<ConnectionBloc>().add(GetInitialState());
                    });
                  } else if (state is PrinterConnectionError) {
                    showAppSnackBar(context, state.message);
                    context.read<ConnectionBloc>().add(GetLoadedState());
                  } else if (state is NfcConnectionError) {
                    showAppSnackBar(context, state.message);
                    context.read<ConnectionBloc>().add(GetLoadedState());
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
