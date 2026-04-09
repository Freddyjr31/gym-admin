import 'package:cook_ledger/core/helpers/show_content_dialog_dynamic.dart';
import 'package:cook_ledger/presentation/providers/exchange_rate_provider.dart';
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

    /// Provider
    final exhangeRateProvider = context.watch<RateExchangeProvider>();
    echangeRate = exhangeRateProvider.getExchangeRate();

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
                          onPressed: () {
                            final exchangeRate = double.tryParse(_exchangeRateController.text) ?? 0.0;
                            exhangeRateProvider.setExhangeRate(exchangeRate);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
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
