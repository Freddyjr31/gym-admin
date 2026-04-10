import 'package:cook_ledger/core/helpers/show_content_dialog_dynamic.dart';
import 'package:cook_ledger/presentation/providers/exchange_rate_provider.dart';
import 'package:cook_ledger/presentation/providers/fixed_cost_provider.dart';
import 'package:cook_ledger/presentation/screens/form_screen.dart';
import 'package:cook_ledger/presentation/screens/home_screen.dart';
import 'package:cook_ledger/presentation/screens/list_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class NavigationScreen extends StatefulWidget {

  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  /// Indice de la navegación
  int _selectedIndex = 0;
  /// Tasa de cambio
  double echangeRate = 0.0;

  /// key del formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controlador de la tasa de cambio
  final TextEditingController _exchangeRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final exhangeRateProvider = context.read<RateExchangeProvider>();
      echangeRate = exhangeRateProvider.getExchangeRate();
    });
  }

  @override
  Widget build(BuildContext context) {

    /// Provider de tasa de cambio
    final exhangeRateProvider = context.watch<RateExchangeProvider>();
    echangeRate = exhangeRateProvider.getExchangeRate();
    /// provider degastos mensuales o fijos
    final fixedCostProvider = context.watch<FixedCostProvider>();

    return NavigationView(
      titleBar: TitleBar(
        title: Text('Cook Ledger'),
        isBackButtonEnabled: false,
        isBackButtonVisible: false,
        endHeader: Tooltip(
          message: '1 USD = $echangeRate VES',
          child: Button(
            child:   RichText(
              textAlign: TextAlign.end,
              text: TextSpan(
                text: 'Tasa de cambio: ',
                style: TextStyle(color: Colors.white),
                children: <TextSpan>[
                  TextSpan(
                    text: echangeRate.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.lightest
                      ),
                  ),
                ],
              ),
            ),
            onPressed: () => ShowContentDialogDynamic.showContentDialogDynamic(
              context,
              //* Cambiar tasa de cambio en un dialog con un input
              ContentDialog(
                title: Text('Tasa de cambio'),
                content: Form(
                  key: _formKey,
                  child: Column(
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
                            onPressed: () {
                              if(_formKey.currentState!.validate()) {
                                final exchangeRate = double.tryParse(_exchangeRateController.text) ?? 0.0;
                                exhangeRateProvider.setExhangeRate(exchangeRate);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ),
          ),
        ),
      ),
      
      pane: NavigationPane(
        selected: _selectedIndex,
        displayMode: PaneDisplayMode.auto,
        onChanged: (index) => setState(() => _selectedIndex = index),
        onItemPressed: (value) async {

          //* obtener gastos fijos para verificar si hay o no
          if (value == 2 && fixedCostProvider.getFixedCost() == 0) {
            await displayInfoBar(context, builder: (context, close) {
              return InfoBar(
                title: const Text('No hay gastos fijos configurados'),
                content: Text('Diríjase a la sección de gastos fijos en el inicio para configurarlos'),
                severity: InfoBarSeverity.error,
              );
            });

            //* Si el usuario intenta ir a la sección de registro sin tener gastos fijos configurados, se le muestra un mensaje de error y se le indica que debe configurar los gastos fijos en el inicio antes de poder acceder a esa sección.
            //* redirige al usuario a la sección de gastos fijos en el inicio para que pueda configurarlos antes de acceder a la sección de registro.
            setState(() => _selectedIndex = 0);
          }

        },
        header: const Text('Panel de navigación'),
        items: [
          PaneItem(
            icon: Icon(FluentIcons.home),
            title: Text('Inicio'),
            body: HomeScreen(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.list),
            title: Text('Lista de recetas'),
            body: ListScreen(),
          ),
          PaneItem(
            icon: Icon(FluentIcons.form_library),
            title: Text('Registro'),
            // body: FormScreen(),
            body:  RecipeFormScreen(),
          ),
        ],
      ),
    );
  }
}
