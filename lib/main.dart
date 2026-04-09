import 'dart:developer';
import 'dart:io';

import 'package:cook_ledger/core/utils/Logs/log_service.dart';
import 'package:cook_ledger/data/datasource/Local/hive_config/hive_config.dart';
import 'package:cook_ledger/presentation/providers/exchange_rate_provider.dart';
import 'package:cook_ledger/presentation/providers/fixed_cost_provider.dart';
import 'package:cook_ledger/presentation/screens/navigation_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
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
        scrollbarTheme: ScrollbarThemeData(
          thickness: 5, // Grosor cuando no se interactúa
          mainAxisMargin: 50,
          hoveringThickness: 5.0, // Grosor cuando pasas el mouse
          scrollbarColor: Colors.white,
          minThumbLength: 50.0,
          radius: Radius.circular(10),
          padding: EdgeInsets.all(2),
          hoveringPadding: EdgeInsets.all(5)
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: NavigationScreen(),
    );
  }
}
