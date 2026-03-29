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

    //* obtener valor de la suma para el costo del platillo
    double recipeCostBS = 
        (
          double.parse(recipeModel.recipeCostModel!.economicSummary.totalIngredientsCost.split("Bs.").first.trim()) + 
          double.parse(recipeModel.recipeCostModel!.economicSummary.unitFixedExpenses.split("Bs.").first.trim())
        ) * recipeModel.recipeCostModel!.exchangeRate;

    double recipeCostUSD =
      double.parse(
        recipeModel.recipeCostModel!.economicSummary.totalIngredientsCost.split("Bs.").first.trim()
        ) +
      double.parse(
        recipeModel.recipeCostModel!.economicSummary.unitFixedExpenses.split("Bs.").first.trim()
        );

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
                            text: "${recipeCostUSD.toStringAsFixed(2)} USD/${recipeCostBS.toStringAsFixed(2)} Bs.",
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
                      children: [
                        //* Contenido de la receta
                        
                        Text("Contenido de la receta", style: FluentTheme.of(context).typography.subtitle),

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