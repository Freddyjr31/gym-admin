
import 'package:gym_admin/data/datasource/Local/recipe_adapter.dart';
import 'package:gym_admin/data/datasource/Local/recipe_cost_adapter.dart';
import 'package:gym_admin/data/datasource/Local/reipe.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class HiveConfig {
  static Future<void> init() async {

    final dir = await getApplicationSupportDirectory();
    final path = '${dir.path}/gym_admin/hive';
    
    await Hive.initFlutter(path);

    _registerAdapters();
    
    // Opcional: Abrir las cajas principales aquí mismo
    recipeBox = await Hive.openBox<RecipeModel>('recipesBox');
  }

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
  }
}