import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:gym_admin/data/datasource/Local/adapters/recipe_adapter.dart';
import 'package:gym_admin/data/datasource/Local/boxes.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  String selectedRecipe = '';

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
            physics: const BouncingScrollPhysics(),
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
        Expander(
          leading: Image.asset(
            //* imagen de la receta (directorio local)
            "assets/images/Polloasadopixelart.png",
            height: 40,
            width: 80,
            fit: BoxFit.cover,
          ),
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
                    )
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(FluentIcons.delete, size: 20),
                  onPressed: () => _removeItem(index),
                ),
            ]),
          ),
          content: SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8,
                      children: [

                        Card(
                          padding: const EdgeInsets.all(8.0),
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
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
                                                  text: '${protein.buyKgWeight} Bs',
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
                                                              text: '${item.kgCost} Bs',
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
                                          ),


                                    
                                        ],
                                      ),
                                    ),
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
}