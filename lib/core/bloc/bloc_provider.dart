import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_demo_zebra/init_dependencies.dart';

import '../../features/connection/presentation/bloc/connection_bloc.dart';
import '../../features/printer/presentation/bloc/printersend_bloc.dart';

class BlocProviders{
  BlocProviders._();
  static final dynamic providers = [
    BlocProvider<ConnectionBloc>(create: (context)=> serviceLocator<ConnectionBloc>()),
    BlocProvider<PrintersendBloc>(create: (context)=> serviceLocator<PrintersendBloc>()),
    // BlocProvider<LicenseBloc>(create: (context)=> serviceLocator<LicenseBloc>()),
    // BlocProvider<SplashBloc>(create: (context)=> serviceLocator<SplashBloc>()),
  ];

}