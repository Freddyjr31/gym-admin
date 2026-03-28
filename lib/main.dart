import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:gym_admin/data/datasource/Local/recipe_adapter.dart';
import 'package:gym_admin/data/datasource/Local/recipe_cost_adapter.dart';
import 'package:gym_admin/data/datasource/Local/reipe.dart';
import 'package:gym_admin/presentation/providers/exchange_rate_provider.dart';
import 'package:gym_admin/presentation/providers/fixed_cost_provider.dart';
import 'package:gym_admin/presentation/screens/navigation_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //* Initialize Hive
  await Hive.initFlutter();

  final dir = await getApplicationSupportDirectory();
  log("📁 Hive está guardando datos en: ${dir.path}");

  // if(kDebugMode) {
  //   await Hive.deleteBoxFromDisk('recipesBox'); // <--- BORRA LA CAJA SI DA ERROR
  // }

  //* ======== Registrar adapters

  //* para datos de entrada (Formulario)
  Hive.registerAdapter(RecipeModelAdapter());
  Hive.registerAdapter(PrincipalProteinModelAdapter());
  Hive.registerAdapter(AdditionalIngredientsAdapter());
  Hive.registerAdapter(SectionsAdapter());
  Hive.registerAdapter(ItemsSectionsAdapter());
  //* para datos de salida (Resultados calculados)
  Hive.registerAdapter(WasteCalculationsCostAdapter());
  Hive.registerAdapter(PortionCostAdapter());
  Hive.registerAdapter(MainIngredientCostAdapter());
  Hive.registerAdapter(AdditionalItemCostAdapter());
  Hive.registerAdapter(AdditionalSectionCostAdapter());
  Hive.registerAdapter(EconomicSummaryCostAdapter());
  Hive.registerAdapter(BusinessMaintenanceCostAdapter());
  Hive.registerAdapter(RecipeCostModelAdapter());


  //* Abre la "caja" (tabla/colección) donde guardarás las recetas
  recipeBox = await Hive.openBox<RecipeModel>('recipesBox');

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
