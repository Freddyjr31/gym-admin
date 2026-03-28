
import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:gym_admin/presentation/providers/exchange_rate_provider.dart';
import 'package:gym_admin/presentation/providers/fixed_cost_provider.dart';
import 'package:provider/provider.dart';

//* Formulario de registro de gastos fijos
class FixedCostField {
  final TextEditingController _nameCostController;
  final TextEditingController _costController;

  FixedCostField({
    String nameCost = '',
    double cost = 0.0
  }) : _nameCostController = TextEditingController(text: nameCost), _costController = TextEditingController();
}

class FormFixedCost extends StatefulWidget {

  const FormFixedCost({super.key});

  @override
  State<FormFixedCost> createState() => _FormFixedCostState();
}

class _FormFixedCostState extends State<FormFixedCost> {

  final _formKey = GlobalKey<FormState>();
  
  final  List<FixedCostField> _fixedCostList = [];

  @override
  void initState() {
    super.initState();
    _fixedCostList.add(FixedCostField(nameCost: 'Local',));
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  _addFixedCost() {
    setState(() {
      _fixedCostList.add(FixedCostField());
    });
  }

  _deleteFixedCost(int index) {
    setState(() {
      _fixedCostList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    final exchangeRateProvider = context.read<RateExchangeProvider>();
    final fixedCostProvider = context.read<FixedCostProvider>();

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
      
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Costos Fijos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    // Botón para añadir costos fijos
                    FilledButton(
                      onPressed: () => _addFixedCost(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.add),
                          SizedBox(width: 8),
                          Text('Agregar costos'),
                        ],
                      ),
                    ),
                  ],
                ),
      
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _fixedCostList.length,
                  itemBuilder: (context, index) {
                  final cost = _fixedCostList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    
                        SizedBox(
                          width: size.width * 0.12,
                          child: InfoLabel(
                            label: 'Nombre',
                            child: TextFormBox(
                              controller: cost._nameCostController,
                              placeholder: 'Ej: Local, electrica, agua..',
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                            ),
                          ),
                        ),
                    
                        SizedBox(
                          width: size.width * 0.12,
                          child: InfoLabel(
                            label: 'Costo',
                            child: TextFormBox(
                              controller: cost._costController,
                              placeholder: 'Ej: 10000',
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                            ),
                          ),
                        ),
                    
                        //* Botón para eliminar sección
                        IconButton(
                          onPressed: () => _deleteFixedCost(index),
                          icon: Icon(
                            FluentIcons.delete,
                            color: Colors.white,
                            ),
                        ),
                      ],
                    ),
                  );
                }),
      
                const SizedBox(height: 20),
      
                //* Botón para guardar los datos
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button(
                      child: const Text('Guardar gastos'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          //* sumar los costos
                          double totalCost = 0;
                          double exchangeRate = exchangeRateProvider.getExchangeRate();

                          for (var cost in _fixedCostList) {
                            totalCost += double.parse(cost._costController.text);
                          }

                          log( 'Costo total: $totalCost bs/usds' );

                          double totalAllCost = fixedCostProvider.calculatedFixedCost(
                            totalCost, exchangeRate
                            );

                          fixedCostProvider.setFixedCost(totalAllCost);

                          log( 'Tasa de cambio: $exchangeRate' );
                          log( 'Costo total: $totalAllCost' );

                          await displayInfoBar(context, builder: (context, close) {
                              return InfoBar(
                                title: const Text('Gastos calculados'),
                                content: Text('Costo total: $totalAllCost'),
                                action: IconButton(
                                  icon: const WindowsIcon(WindowsIcons.check_mark),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                severity: InfoBarSeverity.success,
                              );
                            });
                        
                        }
                      },
                    ),
                  ],
                ),
      
            ],
          ),
        ),
      ),
    );
  }
}

class ExchangeRateProvider {
}
