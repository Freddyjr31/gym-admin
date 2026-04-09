
import 'package:cook_ledger/data/datasource/Local/adapters/fixed_cost_adapter.dart';
import 'package:cook_ledger/data/datasource/Local/adapters/recipe_adapter.dart';
import 'package:cook_ledger/data/datasource/Local/adapters/recipe_cost_adapter.dart';
import 'package:cook_ledger/data/datasource/Local/boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class HiveConfig {

  /// Inicializa Hive, registra los adaptadores y abre las cajas principales
  static Future<void> init() async {

    final dir = await getApplicationSupportDirectory();
    final path = '${dir.path}/cook_ledger/hive';
    
    await Hive.initFlutter(path);

    _registerAdapters();
    
    recipeBox = await Hive.openBox<RecipeModel>('recipesBox');
    fixedCostBox = await Hive.openBox<FixedCostAdapter>('fixedCostBox');
  }

  /// Registra todos los adaptadores de Hive necesarios para la aplicación
  static void _registerAdapters() {
    //* Datos de entrada
    Hive.registerAdapter(RecipeModelAdapter());
    Hive.registerAdapter(PrincipalProteinModelAdapter());
    Hive.registerAdapter(AdditionalIngredientsAdapter());
    Hive.registerAdapter(SectionsAdapter());
    Hive.registerAdapter(ItemsSectionsAdapter());

    //* Datos de salida (Resultados calculados)
    Hive.registerAdapter(WasteCalculationsCostAdapter());
    Hive.registerAdapter(PortionCostAdapter());
    Hive.registerAdapter(MainIngredientCostAdapter());
    Hive.registerAdapter(AdditionalItemCostAdapter());
    Hive.registerAdapter(AdditionalSectionCostAdapter());
    Hive.registerAdapter(EconomicSummaryCostAdapter());
    Hive.registerAdapter(BusinessMaintenanceCostAdapter());
    Hive.registerAdapter(RecipeCostModelAdapter());

    //* costos fijos
    Hive.registerAdapter(FixedCostAdapterAdapter());
    Hive.registerAdapter(FixedCostItemAdapter());
  }
}