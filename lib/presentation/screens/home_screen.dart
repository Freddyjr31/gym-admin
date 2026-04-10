

import 'package:cook_ledger/core/helpers/show_content_dialog_dynamic.dart';
import 'package:cook_ledger/core/utils/Logs/log_service.dart';
import 'package:cook_ledger/data/datasource/Local/boxes.dart';
import 'package:cook_ledger/presentation/providers/exchange_rate_provider.dart';
import 'package:cook_ledger/presentation/providers/fixed_cost_provider.dart';
import 'package:cook_ledger/presentation/widgets/form_fixed_cost.dart';
import 'package:cook_ledger/presentation/widgets/total_recipes_count.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String version = '';

  final TextEditingController _exchangeRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final exchangeRateProvider = context.read<RateExchangeProvider>();

      if (exchangeRateProvider.getExchangeRate() == 0 ) {
        
        ShowContentDialogDynamic.showContentDialogDynamic(
              context,
              //* Cambiar tasa de cambio en un dialog con un input
              ContentDialog(
                title: Text('Tasa de cambio'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InfoLabel(
                      label: 'Nueva tasa de cambio',
                      child: TextFormBox(
                        controller: _exchangeRateController,
                        placeholder: '0.50',
                        validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button(
                          child: const Text('Cancelar'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Button(
                          child: const Text('Guardar'),
                          onPressed: () async{
                            final exchangeRate = double.tryParse(_exchangeRateController.text) ?? 0.0;
                            exchangeRateProvider.setExhangeRate(exchangeRate);
                            await updateFixedCost(context);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              )
            );
      }

      await updateFixedCost(context);
    });
    
  }

  /// Función para cargar la versión de la aplicación desde PackageInfo
  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = '${info.version} (${info.buildNumber})';
      debugPrint('Versión cargada: ${info.version}');
    });
  }

    /// Obtener fixed cost de la caja de Hive y actualizar el estado
  Future<void> updateFixedCost(BuildContext context) async {
    // 1. Cálculo 
    final double total = fixedCostBox.values.fold(0.0, (sum, element) {
      // Aquí asumo que 'element' es el objeto que contiene la lista 'fixedCostItems'
      return sum + element.fixedCostItems.fold(0.0, (itemSum, item) => itemSum + item.cost);
    });
    // 2. Actualizar el estado (Asegúrate de que 'fixedCost' sea el nombre correcto del campo en tu modelo)
    final fixedCostProvider = context.read<FixedCostProvider>();
    final exchangeRateProvider = context.read<RateExchangeProvider>();
    fixedCostProvider.setFixedCostInUSD(total);
    double costCalculated = fixedCostProvider.calculatedFixedCost(total, exchangeRateProvider.getExchangeRate());
    fixedCostProvider.setFixedCost(costCalculated);
    LoggerService.write('fixedCost actualizado: $costCalculated');
  }


  @override
  Widget build(BuildContext context) {

    // final size = MediaQuery.of(context).size;
    final fixedCostProvider = context.watch<FixedCostProvider>();

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
                            child: Row(
                              children: [
                                Text('Gastos fijos: ${fixedCostBox.length}'),
                                const Spacer(),
                                //* total de gastos fijos registrados
                                Text(
                                  "${fixedCostProvider.getFixedCost().toStringAsFixed(2)} Bs. / ${fixedCostProvider.getFixedCostInUSD().toStringAsFixed(2)} \$", 
                                  style: FluentTheme.of(context).typography.bodyLarge?.copyWith(
                                    color: Colors.green.lightest,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: FluentTheme.of(context).scaffoldBackgroundColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: ListTile.selectable(
                                            selectionMode: ListTileSelectionMode.single,
                                            title: Text(
                                              fixedCost?.fixedCostItems.map((e) => e.nameCost).join(', ') ?? 'Gasto fijo ${index + 1}',
                                              style: FluentTheme.of(context).typography.bodyStrong,
                                              ),
                                            subtitle: RichText(
                                              text: TextSpan(
                                                text: 'Total: ',
                                                style: FluentTheme.of(context).typography.body,
                                                children: [
                                                  TextSpan(
                                                    text: '${fixedCost?.fixedCostItems.fold(0.0, (sum, element) => sum + element.cost)} \$ / ${fixedCostProvider.calculatedFixedCost(fixedCost?.fixedCostItems.fold(0.0, (sum, element) => sum + element.cost) ?? 0.0, context.read<RateExchangeProvider>().getExchangeRate()).toStringAsFixed(2)} Bs.',
                                                    style: FluentTheme.of(context).typography.body?.copyWith(
                                                      color: Colors.green.lightest,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(FluentIcons.delete),
                                              onPressed: () async {
                                                fixedCostBox.deleteAt(index);
                                                await updateFixedCost(context);
                                                setState(() {});
                                              },
                                            ),
                                          ),
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