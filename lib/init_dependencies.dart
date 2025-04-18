import 'package:get_it/get_it.dart';
import 'package:print_demo_zebra/features/connection/data/data_source/zebra_printer.dart';
import 'package:print_demo_zebra/features/connection/data/repo_impl/connection_repo_impl.dart';
import 'package:print_demo_zebra/features/connection/domain/repository/connection_repository.dart';
import 'package:print_demo_zebra/features/connection/domain/usecase/connect_printer_usecase.dart';
import 'package:print_demo_zebra/features/connection/domain/usecase/connection_usecase.dart';
import 'package:print_demo_zebra/features/connection/presentation/bloc/connection_bloc.dart';
import 'features/printer/data/datasource/printer_discovery.dart';
import 'features/printer/data/repo_impl/printer_send_repo_impl.dart';
import 'features/printer/domain/repository/printer_send_repository.dart';
import 'features/printer/domain/usecase/printer_send_usecase.dart';
import 'features/printer/presentation/bloc/printersend_bloc.dart';


var serviceLocator = GetIt.instance;
Future<void> initDependencies() async {
  _initBody();
}

void _initBody() {
  serviceLocator
    ..registerFactory<ZebraPrinterService>(() => ZebraPrinterServiceImpl())
    ..registerFactory<ConnectionRepository>(
        () => ConnectionRepoImpl(serviceLocator<ZebraPrinterService>()))
    ..registerFactory<ConnectionUsecase>(
        () => ConnectionUsecase(serviceLocator<ConnectionRepository>()))
    ..registerLazySingleton<ConnectionBloc>(
        () => ConnectionBloc(conUsecase: serviceLocator<ConnectionUsecase>(),conPrinter: serviceLocator<ConnectPrinterUsecase>()))
    ..registerFactory<PrinterSendDatasource>(() => PrinterSendDatasourceImpl())
    ..registerFactory<PrinterSendRepository>(() =>
        PrinterSendRepositoryImpl(serviceLocator<PrinterSendDatasource>()))
    ..registerFactory<PrinterSendUseCase>(
        () => PrinterSendUseCase(serviceLocator<PrinterSendRepository>()))
    ..registerLazySingleton<PrintersendBloc>(
        () => PrintersendBloc(serviceLocator<PrinterSendUseCase>()))
  //   ..registerFactory<LocalDataSource>(()=> LocalDataSourceImpl(serviceLocator<SharedPreferences>()))
  //   ..registerFactory<LicensingRemoteDataSource>(()=>LicensingRemoteDataSourceImpl())
  //   ..registerFactory<LicenseRepository>(()=> LicenseRepositoryImpl(serviceLocator<LocalDataSource>(), serviceLocator<LicensingRemoteDataSource>()))
  //   ..registerFactory<LicensingUsecase>(()=> LicensingUsecase(serviceLocator<LicenseRepository>()))
  //   ..registerLazySingleton<LicenseBloc>(()=> LicenseBloc(serviceLocator<LicensingUsecase>()))
    ..registerFactory<ConnectPrinterUsecase>(()=> ConnectPrinterUsecase(serviceLocator<ConnectionRepository>()))
  // ..registerFactory<SplashLocalDataSource>(()=> SplashLocalDataSourceImpl(serviceLocator<SharedPreferences>()))
  // ..registerFactory<SplashRepository>(()=> SplashRepositoryImpl(serviceLocator<SplashLocalDataSource>()))
  // ..registerFactory<SplashUsecase>(()=> SplashUsecase(serviceLocator<SplashRepository>()))
  // ..registerLazySingleton<SplashBloc>(()=> SplashBloc(serviceLocator<SplashUsecase>()))
  ;
}


