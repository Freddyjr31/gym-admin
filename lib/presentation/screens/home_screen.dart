

import 'package:fluent_ui/fluent_ui.dart';
import 'package:gym_admin/data/datasource/Local/boxes.dart';
import 'package:gym_admin/presentation/widgets/form_fixed_cost.dart';
import 'package:gym_admin/presentation/widgets/total_recipes_count.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String version = '';

  @override
  void initState() {
    super.initState();
    loadVersion();
  }


  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = '${info.version} (${info.buildNumber})';
    });
  }


  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: FluentTheme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                spacing: 10,
                children: [
                  //* Fecha de hoy
                  const Icon(FluentIcons.calendar, size: 20),
                  Text(
                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                    style: FluentTheme.of(context).typography.body,
                    ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: FluentTheme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Versión $version',
                style: FluentTheme.of(context).typography.caption
              )
            )
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.max,
          children: [
              
            //* Bienvenida
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              
                      DefaultTextStyle(
                        style: FluentTheme.of(context).typography.titleLarge!,
                        textAlign: TextAlign.start,
                        child: const Text('Bienvenido'),
                      ),
        
                      DefaultTextStyle(
                        style: FluentTheme.of(context).typography.body!,
                        textAlign: TextAlign.start,
                        child: const Text('Hola, listo para continuar tu dieta?'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        
            const Divider(),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Expanded(
                    flex: 1,
                    child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FluentTheme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            style: FluentTheme.of(context).typography.title!,
                            textAlign: TextAlign.start,
                            child: const Text('Resumen de recetas'),
                          ),
                                      
                          //* Total de recetas
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TotalRecipesCount(),
                                ],
                              ),
                            )),
                        ],
                      ),
                    ),
                  ),
                  
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FluentTheme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          DefaultTextStyle(
                            style: FluentTheme.of(context).typography.title!,
                            textAlign: TextAlign.start,
                            child: Text('Gastos fijos: ${fixedCostBox.length}'),
                          ),

                          /// Lista para mostrar los gastos fijos registrados
                          fixedCostBox.length == 0 ? const Text('No hay gastos fijos registrados') : 
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: Column(
                                spacing: 8,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: fixedCostBox.length,
                                    itemBuilder: (context, index) {
                                      final fixedCost = fixedCostBox.getAt(index);
                                      return ListTile(
                                        title: Text(fixedCost?.fixedCostItems.map((e) => e.nameCost).join(', ') ?? 'Gasto fijo ${index + 1}'),
                                        subtitle: Text('Costo total: \$${fixedCost?.fixedCostItems.fold(0, (sum, item) => sum + item.cost).toStringAsFixed(2) ?? '0.00'}'),
                                      );
                                    },
                                  )
                                ],
                              ),
                            )),

                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 10),
                                      
                          //* Total de recetas
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              child: FormFixedCost()
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
      )
    );
  }
}