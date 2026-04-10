import 'dart:convert';
import 'dart:io';

import 'package:cook_ledger/data/datasource/Local/adapters/recipe_adapter.dart';
import 'package:cook_ledger/data/datasource/Local/adapters/recipe_cost_adapter.dart';
import 'package:cook_ledger/data/datasource/Local/boxes.dart';
import 'package:cook_ledger/data/models/calculated_cost_model.dart';
import 'package:cook_ledger/data/models/data_to_calculated.dart';
import 'package:cook_ledger/presentation/providers/exchange_rate_provider.dart';
import 'package:cook_ledger/presentation/providers/fixed_cost_provider.dart';
import 'package:cook_ledger/presentation/providers/recipe_calculator.dart';
import 'package:cook_ledger/presentation/widgets/loading_overlay.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  String selectedRecipe = '';
  bool loadingUpdatePrice = false;
  Set<int> itemsCargando = {};

  /// Exporta las recetas a un archivo JSON en el almacenamiento local
  Future<void> exportRecipes() async {
    final box = Hive.box<RecipeModel>('recipesBox');

    final data = box.values
        .map((recipe) => recipe.toJson())
        .toList();

    final jsonString = jsonEncode(data);

    //* Guardar en archivo
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/recipes_backup.json');
    await file.writeAsString(jsonString);
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return recipeBox.length == 0 ? 
      SizedBox(
        width: size.width,
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(FluentIcons.critical_error_solid, size: 40),
            Text('Aun no hay recetas disponibles', style: FluentTheme.of(context).typography.body),
          ],
        ),
      ) : 
      Column(
      spacing: 8,
      children: [

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                message: 'Actualizar todos los precios',
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateColor.resolveWith(
                      (states) => Colors.green.lightest.withAlpha(30),
                    ),
                    foregroundColor: WidgetStateColor.resolveWith(
                      (states) => Colors.green.lightest,
                    ),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Text('Actualizar precios', style: FluentTheme.of(context).typography.body),
                      const Icon(FluentIcons.circle_dollar, size: 20), // Cambié el icono para diferenciar
                    ],
                  ),
                  onPressed: () async {
                    // Generamos una lista de 0 hasta el final de la caja
                    List<int> allindexs = List.generate(recipeBox.length, (index) => index);
                    
                    await _updateItem(context, allindexs);
                  },
                ),
              ),

              //* Exportar datos
              Tooltip(
                message: 'Exportar datos',
                child: Button(
                  onPressed: () {
                      exportRecipes();
                    },
                  child: Row(
                    children: [
                      Text('Exportar', style: FluentTheme.of(context).typography.body),
                      const SizedBox(width: 8),
                      Icon(FluentIcons.download, size: 16)
                    ],
                  ),
                ),
              ),
            ]
          ),
        ),

        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: recipeBox.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index, animation) {
              final recipeModel = recipeBox.getAt(index);

              return _buildAnimatedItem(
                context,
                recipeModel,
                index,
                animation,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedItem(
    BuildContext context,
    RecipeModel recipeModel,
    int index,
    Animation<double> animation,
  ) {

    //* obtengo el nombre las proteinas principales por si tiene mas de uno
    String principalProteins = '';
    for (var element in recipeModel.principalProtein) {
      principalProteins += '${element.name}, ';
    }
    principalProteins = principalProteins.substring(0, principalProteins.length - 2);

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: 
        LoadingGradientOverlay(
          // isLoading: loadingUpdatePrice,
          isLoading: itemsCargando.contains(index),
          child: Expander(
            leading: Image.asset(
              //* imagen de la receta (directorio local)
              "assets/images/Polloasadopixelart.png",
              height: 40,
              width: 80,
              fit: BoxFit.cover,
            ),
            headerBackgroundColor: WidgetStateColor.resolveWith(
              (states) => Colors.white.withAlpha(20),
            ),
            contentPadding: EdgeInsets.all(0),
            direction: ExpanderDirection.down,
            header: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 8,
                children: [
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipeModel.name,
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Proteinas principales: ',
                          style: TextStyle(
                            color: Colors.white.withAlpha(100),
                            ),
                          children: <TextSpan>[
                            TextSpan(
                              text: principalProteins,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal
                                ),
                            ),
                          ],
                        ),
                      ),
          
                      RichText(
                        text: TextSpan(
                          text: 'Costo: ',
                          style: TextStyle(
                            color: Colors.white.withAlpha(100),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: recipeModel.recipeCostModel!.economicSummary.suggestedSalesPrice.toString(),
                              style: TextStyle(
                                color: Colors.green.lightest,
                                fontWeight: FontWeight.normal
                                ),
                            ),
                          ],
                        ),
                      ),
          
                        RichText(
                          text: TextSpan(
                            text: 'Tasa de cambio de creación: ',
                            style: TextStyle(
                              color: Colors.white.withAlpha(100),
                              ),
                            children: <TextSpan>[
                              TextSpan(
                                text: recipeModel.recipeCostModel!.exchangeRate.toString(),
                                style: TextStyle(
                                  color: Colors.green.lightest,
                                  fontWeight: FontWeight.normal
                                  ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
          
                  //* Boton de actualizar precios en base al dolar
                  Tooltip(
                    message: 'Actualizar precios',
                    child: IconButton(
                      icon: const Icon(FluentIcons.circle_dollar, size: 20),
                      onPressed: () async {
                        // setState(() {
                        //   //loadingUpdatePrice = !loadingUpdatePrice;
                        //   itemsCargando.add([index]);
                        // });

                        // await Future.delayed(const Duration(seconds: 3), () => _updateItem(context, recipeModel, index));
            
                        // setState(() {
                        //   //loadingUpdatePrice = !loadingUpdatePrice;
                        //   itemsCargando.remove([index]);
                        // });

                        await _updateItem(context, [index]);
                        },
                    ),
                  ),
          
                  //* Boton de eliminar
                  Tooltip(
                    message: 'Eliminar receta',
                    child: IconButton(
                      icon: const Icon(FluentIcons.delete, size: 20),
                      onPressed: () => _removeItem(index),
                    ),
                  ),
              ]),
            ),
            content: Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  
                  //* Fondo oscuro al final del contenido para mejorar la legibilidad
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 70, 
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent, // Arriba transparente
                              // Aquí usamos un color oscuro (puedes usar Colors.black o el fondo de tu app)
                              Colors.black.withAlpha(153), 
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          
                  SingleChildScrollView(
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.all(8.0),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                    
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            spacing: 8,
                            children: [
                                
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  
                                  //* Contenido de la receta
                                  Text('Proteinas principales:', style: FluentTheme.of(context).typography.title),
                                
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white.withAlpha(50)),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: recipeModel.principalProtein.length,
                                      itemBuilder: (context, index) {
                                        final protein = recipeModel.principalProtein[index];
                                        return ListTile(
                                          title: Text(protein.name, style: FluentTheme.of(context).typography.subtitle),
                                          subtitle: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            spacing: 8,
                                            children: [
                                              
                                              RichText(
                                                text: TextSpan(
                                                  text: 'Cantidad: ',
                                                  style: TextStyle(
                                                    color: Colors.white.withAlpha(100),
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: '${protein.buyWeight} kg',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.normal
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        
                                              RichText(
                                                text: TextSpan(
                                                  text: 'Costo: ',
                                                  style: TextStyle(
                                                    color: Colors.white.withAlpha(100),
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: '${protein.buyKgWeight} \$',
                                                      style: TextStyle(
                                                        color: Colors.green.lightest,
                                                        fontWeight: FontWeight.normal
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        
                                              RichText(
                                                text: TextSpan(
                                                  text: '% de Merma: ',
                                                  style: TextStyle(
                                                    color: Colors.white.withAlpha(100),
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: '${protein.shrikagepercentage} %',
                                                      style: TextStyle(
                                                        color: Colors.green.lightest,
                                                        fontWeight: FontWeight.normal
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        
                                              RichText(
                                                text: TextSpan(
                                                  text: 'Peso por porcion: ',
                                                  style: TextStyle(
                                                    color: Colors.white.withAlpha(100),
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: '${protein.weightPortionKg} kg',
                                                      style: TextStyle(
                                                        color: Colors.green.lightest,
                                                        fontWeight: FontWeight.normal
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                          
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const SizedBox(height: 5),
                                          
                                  if(recipeModel.additionalsingredients!.sections.isNotEmpty) ...[
                                    
                                    Text('Ingredientes adicionales:', style: FluentTheme.of(context).typography.title),
                                          
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white.withAlpha(50)),
                                      ),
                                      child: ListView.builder(
                                        //* Ingredientes adicionales
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: recipeModel.additionalsingredients?.sections.length,
                                        itemBuilder: (context, index) {
                                          final ingredient = recipeModel.additionalsingredients?.sections[index];
                                          return ListTile(
                                            title: Text(ingredient!.name, style: FluentTheme.of(context).typography.subtitle),
                                            subtitle: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 8,
                                              children: [
                                                ...ingredient.items.map((item) => Row(
                                                  spacing: 5,
                                                  mainAxisSize: MainAxisSize.max,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(item.name == '' ? 'Sin nombre' : item.name, style: FluentTheme.of(context).typography.body)),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        spacing: 8,
                                                        children: [
                                                          const SizedBox(width: 2),
                                                          RichText(
                                                            text: TextSpan(
                                                              text: 'Cantidad usada: ',
                                                              style: TextStyle(
                                                                color: Colors.white.withAlpha(100),
                                                              ),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: '${item.count} kg',
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.normal
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          RichText(
                                                            text: TextSpan(
                                                              text: 'Costo por kg: ',
                                                              style: TextStyle(
                                                                color: Colors.white.withAlpha(100),
                                                              ),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: '${item.kgCost} \$',
                                                                  style: TextStyle(
                                                                    color: Colors.green.lightest,
                                                                    fontWeight: FontWeight.normal
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Divider(),
                                                  ],
                                                )
                                                ),
                                          
                                                if(index != recipeModel.additionalsingredients!.sections.length - 1) ...[
                                                  const SizedBox(height: 5),
                                                  const Divider(),
                                                  const SizedBox(height: 5),
                                                ]
                                              ],
                                            ),
                                          );
                                        }
                                      )
                                    ),
                                  ],
                                          
                                  Text('Resumen económico:', style: FluentTheme.of(context).typography.title),
                                          
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white.withAlpha(50)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        spacing: 8,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'Costo ingredientes: ',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(100),
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: '${recipeModel.recipeCostModel?.economicSummary.totalIngredientsCost}',
                                                  style: TextStyle(
                                                    color: Colors.green.lightest,
                                                    fontWeight: FontWeight.normal
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      
                                          RichText(
                                            text: TextSpan(
                                              text: 'Gastos fijos por unidad: ',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(100),
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: '${recipeModel.recipeCostModel?.economicSummary.unitFixedExpenses}',
                                                  style: TextStyle(
                                                    color: Colors.green.lightest,
                                                    fontWeight: FontWeight.normal
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      
                                          RichText(
                                            text: TextSpan(
                                              text: 'Ganancia esperada: ',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(100),
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: '${recipeModel.recipeCostModel?.economicSummary.expectedProfit}',
                                                  style: TextStyle(
                                                    color: Colors.green.lightest,
                                                    fontWeight: FontWeight.normal
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      
                                          RichText(
                                            text: TextSpan(
                                              text: 'Precio de venta sugerido: ',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(100),
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: '${recipeModel.recipeCostModel?.economicSummary.suggestedSalesPrice}',
                                                  style: TextStyle(
                                                    color: Colors.green.lightest,
                                                    fontWeight: FontWeight.normal
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ),
                                          
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const SizedBox(height: 5),
                                          
                                  Text('Gastos fijos:', style: FluentTheme.of(context).typography.title),
                                          
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white.withAlpha(50)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        spacing: 8,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          
                                          RichText(
                                            text: TextSpan(
                                              text: 'Gastos generales: ',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(100),
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: '${recipeModel.recipeCostModel?.businessMaintenance.monthlyFixedExpenses}',
                                                  style: TextStyle(
                                                    color: Colors.green.lightest,
                                                    fontWeight: FontWeight.normal
                                                  ),
                                                ),
                                              ]
                                              )
                                            ),
                                          
                                            RichText(
                                              text: TextSpan(
                                                text: 'Gastos fijos por unidad: ',
                                                style: TextStyle(
                                                  color: Colors.white.withAlpha(100),
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: '${recipeModel.recipeCostModel?.businessMaintenance.netProfitperUnit}',
                                                    style: TextStyle(
                                                      color: Colors.green.lightest,
                                                      fontWeight: FontWeight.normal
                                                    ),
                                                  ),
                                                ]
                                                )
                                              ),
                                          
                                            RichText(
                                              text: TextSpan(
                                                text: 'Cantidad para rentabilidad: ',
                                                style: TextStyle(
                                                  color: Colors.white.withAlpha(100),
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: '${recipeModel.recipeCostModel?.businessMaintenance.unitsForBreakEven}',
                                                    style: TextStyle(
                                                      color: Colors.green.lightest,
                                                      fontWeight: FontWeight.normal
                                                    ),
                                                  ),
                                                ]
                                                )
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  /// Elimina un item de la lista y de la base de datos con animación
  void _removeItem(int index) {
    final removedItem = recipeBox.getAt(index);

    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _buildAnimatedItem(
        context,
        removedItem,
        index,
        animation,
      ),
      duration: const Duration(milliseconds: 300),
    );

    recipeBox.deleteAt(index);
  }

  //* Función para actulizar los precios de una receta en base de la tasa del USD
  _updateItem(BuildContext context, /*RecipeModel recipeModel,*/ List<int> indexs) async {

    //* provider de cambio de moneda
    final exchangeRateProvider = context.read<RateExchangeProvider>();
    //* provider de gastos fijos
    final fixedCostProvider = context.read<FixedCostProvider>();
    
    //* inyecto los costos fijos y la tasa
    final calculator = RecipeCalculator(
      monthlyFixedExpenses: fixedCostProvider.getFixedCost(),
      usdExchangeRate: exchangeRateProvider.getExchangeRate()
    );

    // 1. Marcamos como cargando todos los índices recibidos
    setState(() {
      itemsCargando.addAll(indexs);
    });

    for (var index in indexs) {

      final recipeModel = recipeBox.getAt(index);
      if (recipeModel == null) continue;
      
      await Future.delayed(const Duration(seconds: 3));

        //* prepara el modelo para el calculo
        RecipeCalculation calculatedCost = calculator.calculateRecipeCosts(
          RecipeRequestModel(
            recipeName: recipeModel.name,
            mainIngredients: recipeModel.principalProtein.map<MainIngredient>((item) => MainIngredient(
              name: item.name,
              purchaseWeightKg: item.buyKgWeight,
              purchasePricePerKg: item.buyWeight,
              wastePercentage: item.shrikagepercentage,
              weightPerPortionKg: item.weightPortionKg
            )).toList(),
            additionalSectionsRequest: recipeModel.additionalsingredients!.sections.map<AdditionalSectionRequest>((item) => AdditionalSectionRequest(
              name: item.name,
              items: item.items.map<Item>((item) => Item(
                name: item.name,
                pricePerKg: item.kgCost.toDouble(),
                quantityKg: item.count.toDouble()
              )).toList()
            )).toList(),
            fixedCostsAndMargin: FixedCostsAndMargin(
              breadUnit: recipeModel.fixedCostsAndMargin?.breadUnit ?? 0, 
              packagingUnit: recipeModel.fixedCostsAndMargin?.packagingUnit ?? 0, 
              operatingCost: recipeModel.fixedCostsAndMargin?.operatingCost ?? 0, 
              desiredProfitPercentage: recipeModel.fixedCostsAndMargin?.desiredProfitPercentage ?? 0
              )
          )
        );
        //* guuardos los datos del calculo en bd
        try {

          final recipeModelToSave = RecipeModel(
            name: recipeModel.name,
            principalProtein: recipeModel.principalProtein,
            additionalsingredients: recipeModel.additionalsingredients,
            fixedCostsAndMargin: recipeModel.fixedCostsAndMargin,
            recipeCostModel: RecipeCostModel(
              recipeName: recipeModel.name,
              exchangeRate: calculatedCost.exchangeRate,
              mainIngredients: recipeModel.recipeCostModel!.mainIngredients,
              additionalSections: recipeModel.recipeCostModel!.additionalSections,
              economicSummary: EconomicSummaryCost(
                totalIngredientsCost: calculatedCost.economicSummary.totalIngredientsCost,
                expectedProfit: calculatedCost.economicSummary.expectedProfit,
                unitFixedExpenses: calculatedCost.economicSummary.unitFixedExpenses,
                suggestedSalesPrice: calculatedCost.economicSummary.suggestedSalesPrice
                ),
              businessMaintenance: BusinessMaintenanceCost(
                monthlyFixedExpenses: calculatedCost.businessMaintenance.monthlyFixedExpenses,
                netProfitperUnit: calculatedCost.businessMaintenance.netProfitPerUnit,
                unitsForBreakEven: calculatedCost.businessMaintenance.unitsForBreakEven
              ),
            ),
          );

          //* Guarda la receta en la "caja"
          await recipeBox.putAt(index, recipeModelToSave);

        } catch (e) {
          // Manejo de errores, por ejemplo, mostrar un mensaje al usuario
          debugPrint('Error al actualizar la receta: $e');
          return await displayInfoBar(context, builder: (context, close) {
              return InfoBar(
                title: const Text('Errror al actualizar montos de la receta'),
                content: Text('$e'),
                action: Icon(
                  FluentIcons.check_mark, color: Colors.green, size: 20
                  // onPressed: () => Navigator.pop(context),
                ),
                severity: InfoBarSeverity.error,
              );
            });
        } finally {
          // 3. Marcamos como no cargando el índice actual
          setState(() {
            itemsCargando.removeAll(indexs);
          });
        }
    }
    
  }
}