import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:print_demo_zebra/config/theme.dart';
import 'package:print_demo_zebra/core/constants/app_constants.dart';
import 'package:print_demo_zebra/core/utils/permission_hanlder.dart';
import 'package:print_demo_zebra/features/connection/presentation/view/connection_screen.dart';
import 'core/bloc/bloc_provider.dart';
import 'init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initDependencies();
  await CheckPermission().requestPermissions();
  runApp(MultiBlocProvider(
      providers: BlocProviders.providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.APP_NAME,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: ConnectionScreen(),
    );
  }
}
