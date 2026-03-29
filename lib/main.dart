import 'dart:developer';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:gym_admin/core/utils/Logs/log_service.dart';
import 'package:gym_admin/data/datasource/Local/hive_config/hive_config.dart';
import 'package:gym_admin/presentation/providers/exchange_rate_provider.dart';
import 'package:gym_admin/presentation/providers/fixed_cost_provider.dart';
import 'package:gym_admin/presentation/screens/navigation_screen.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos el logger
  LoggerService.init();
  // Configuramos la captura de errores global
  FlutterError.onError = LoggerService.logFlutterError;

  log("Aplicación iniciada...");
  log(Directory.systemTemp.path);

  try {
    //* Initialize Hive
    LoggerService.write('Iniciando Hive...');
    // await Hive.initFlutter(path);
    await HiveConfig.init();
  } catch (e) {
    log("Error al inicializar Hive: $e");
    LoggerService.write('Excepción en main: $e\n');
    rethrow;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RateExchangeProvider()),
        ChangeNotifierProvider(create: (_) => FixedCostProvider()),
      ],
      child: const MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      themeMode: ThemeMode.dark,
      theme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
        typography: Typography.fromBrightness(brightness: Brightness.dark),
      ),
      debugShowCheckedModeBanner: false,
      home: NavigationScreen(),
    );
  }
}
