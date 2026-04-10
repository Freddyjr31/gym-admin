import 'package:cook_ledger/core/helpers/show_content_dialog_dynamic.dart';
import 'package:cook_ledger/core/utils/Logs/log_service.dart';
import 'package:cook_ledger/data/datasource/Local/adapters/recipe_adapter.dart';
import 'package:cook_ledger/data/datasource/Local/adapters/recipe_cost_adapter.dart';
import 'package:cook_ledger/data/datasource/Local/boxes.dart';
import 'package:cook_ledger/data/models/calculated_cost_model.dart';
import 'package:cook_ledger/data/models/data_to_calculated.dart';
import 'package:cook_ledger/presentation/models/form_state.dart';
import 'package:cook_ledger/presentation/providers/exchange_rate_provider.dart';
import 'package:cook_ledger/presentation/providers/fixed_cost_provider.dart';
import 'package:cook_ledger/presentation/providers/recipe_calculator.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

//* Formulario de registro de nuevas recetas
class RecipeFormScreen extends StatefulWidget {

  const RecipeFormScreen({super.key});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  
  final _formKey = GlobalKey<FormState>();

  //* controladores de texto para cada campo del formulario
  final _nameController = TextEditingController();
  //* controladores de texto para cada proteina
  final  List<PrincipalProtein> _principalProtein = [];

  //* controladores costos fijos y margenes
  final _breadUnitCostController = TextEditingController();
  final _packagingUnit = TextEditingController();
  final _operationCost = TextEditingController();
  final _desiredProfitPercentage = TextEditingController();

  //* Lista de secciones dinámicas
  final List<SectionState> _sections = [];

  //* bool para controlar la visibilidad de los botones de sección
  bool showCalculatedCost = false;

  //* estado para los datos calculados
  late RecipeCalculation recipe;

  late FixedCostsAndMarginAd fixedCostsAndMargin;
  late FixedCostsAndMargin fixedCostsAndMarginModel;

  @override
  void initState() {
    super.initState();
    //* por defecto añado items de cada modelo
    _principalProtein.add(
      PrincipalProtein(initialName: "")
      );
    _sections.add(
      SectionState(initialName: '')
      );
  }

  // @override
  // void dispose() {
  //   _nameController.dispose();
  //   _breadUnitCostController.dispose();
  //   _packagingUnit.dispose();
  //   _operationCost.dispose();
  //   _desiredProfitPercentage.dispose();

  //   for (var section in _sections) {
  //     section.nameController.dispose();
  //     for (var item in section.items) {
  //       item.nameController.dispose();
  //       item.pkgCostController.dispose();
  //       item.countController.dispose();
  //     }
  //   }

  //   for (var principalProtein in _principalProtein) {
  //     principalProtein.shrinkagePercentageController.dispose();
  //     principalProtein.buyWeightController.dispose();
  //     principalProtein.buyKgWeightController.dispose();
  //     principalProtein.weightPortionController.dispose();
  //   }
    
  //   super.dispose();
  // }

  //* Funcion para agregar una proteina
  void _agregarProteina() {
    setState(() {
      _principalProtein.add(PrincipalProtein());
    });
  }

  //* Funcion para eliminar una proteina
  void _eliminarProteina(int index) {
    setState(() {
      _principalProtein.removeAt(index);
    });
  }


  //* ============= FUNCIONES PARA AGREGAR Y ELIMINAR SECCIONES =============
  /// Función para agregar una nueva sección
  void _agregarSeccion() {
    setState(() {
      _sections.add(SectionState());
    });
  }

  /// Función para eliminar una sección
  void _eliminarSeccion(int index) {
    setState(() {
      final section = _sections[index];
      section.nameController.dispose();
      for (var item in section.items) {
        item.nameController.dispose();
        item.pkgCostController.dispose();
        item.countController.dispose();
      }
      _sections.removeAt(index);
    });
  }

  /// Función para agregar un nuevo item
  void _agregarItem(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].items.add(ItemState());
    });
  }

  /// Función para eliminar un item
  void _eliminarItem(int sectionIndex, int itemIndex) {
    setState(() {
      final item = _sections[sectionIndex].items[itemIndex];
      item.nameController.dispose();
      item.pkgCostController.dispose();
      item.countController.dispose();
      _sections[sectionIndex].items.removeAt(itemIndex);
    });
  }

  //* ==================== CONSTRUIR EL MODELO REAL AL ENVIAR (ADDITIONAL INGREDIENTS) ====================
  /// Función para construir el modelo de ingredientes adicionales
  AdditionalIngredients buildAdditionalIngredientsModel() {
    final secciones = _sections.map((section) {
      final items = section.items.map((item) {
        debugPrint('Construyendo item: ${item.nameController.text.trim()}, precio por kg: ${item.pkgCostController.text.trim()}, cantidad usada (kg): ${item.countController.text.trim()}');
        return ItemsSections(
          name: item.nameController.text.trim(),
          kgCost: double.tryParse(item.pkgCostController.text) ?? 0.0,
          count: double.tryParse(item.countController.text) ?? 0.0,
        );
      }).toList();

      return Sections(
        name: section.nameController.text.trim(),
        items: items,
      );
    }).toList();

    return AdditionalIngredients(sections: secciones);
  }

  /// Función para construir el modelo de proteina principal
  List<PrincipalProteinModel> buildPrincipalProteinModel() {

    final proteins = _principalProtein.map((protein) {
      return PrincipalProteinModel(
        name: protein.proteinController.text.trim(),
        buyWeight: double.tryParse(protein.buyWeightController.text.trim()) ?? 0.0, 
        buyKgWeight: double.tryParse(protein.buyKgWeightController.text.trim()) ?? 0.0, 
        shrikagepercentage: double.tryParse(protein.shrinkagePercentageController.text.trim()) ?? 0.0, 
        weightPortionKg: double.tryParse(protein.weightPortionController.text.trim()) ?? 0.0,
      );
    }).toList();

    return proteins;
    
  }

  /// Función para construir el modelo de proteinas adicionales
  List<MainIngredientCost> buildPrincipalProteinCostModel(RecipeCalculation recipeCostModel) {

    final List<MainIngredientCost> proteinsCost = recipeCostModel.mainIngredientResults.map((protein) {
      return MainIngredientCost(
        name: protein.name, 
        wasteCalculations: WasteCalculationsCost(
          initialWeightKg: protein.wasteCalculations.initialWeightKg, 
          wastePercentage: protein.wasteCalculations.wastePercentage, 
          usableWeightKg: protein.wasteCalculations.usableWeightKg, 
          realPricePerKg: protein.wasteCalculations.realPricePerKg.toString()
          ), 
        portion: PortionCost(
          weightUsedKg: protein.portion.weightUsedKg, 
          cost: protein.portion.cost.toString()
        ),
      );
    }).toList();

    return proteinsCost;
  }

  /// Función para construir el modelo de costos adicionales
  List<AdditionalSectionCost> buildAdditionalSectionCostModel(RecipeCalculation recipeCostModel) {

    final List<AdditionalSectionCost> sections = recipeCostModel.additionalSections.map((section) {
      return AdditionalSectionCost(
        sectionName: section.sectionName,
        sectionTotal: section.sectionTotal,
        items: section.items.map((item) {
          debugPrint('--- Item adicional: ${item.name}, precio por kg: ${item.pricePerKg}, cantidad usada (kg): ${item.quantityKg}, subtotal: ${item.subtotal}');
          return AdditionalItemCost(
            name: item.name,
            quantityKg: item.quantityKg,
            pricePerKg: item.pricePerKg.toString(),
            subtotal: item.subtotal.toString() 
          );
        }).toList(), 
      );
    }).toList();

    return sections;

  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    //* provider de cambio de moneda
    final exchangeRateProvider = context.watch<RateExchangeProvider>();
    //* provider de gastos fijos
    final fixedCostProvider = context.watch<FixedCostProvider>();

    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text('Agregar nueva receta'),

            IconButton(
              icon: Icon(
                FluentIcons.refresh,
                size: 20,
                ),
              onPressed: () {
                setState(() {
                  _nameController.clear();
                  _sections.clear();
                  _principalProtein.clear();
                  _breadUnitCostController.clear();
                  _packagingUnit.clear();
                  _operationCost.clear();
                  _desiredProfitPercentage.clear();
                });
              },
                )
          ],
        )
        ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Nombre de la receta
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: 'Nombre de la receta',
                      child: TextFormBox(
                        controller: _nameController,
                        placeholder: 'Sandwich de pollo',
                        validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                ],
              ),

              const SizedBox(height: 25),

              Divider(
                size: size.width,
                style: DividerThemeData(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.grey[50]),
                    ),
                  )
                ),
              ),

              const SizedBox(height: 25),

              //* ==================== Sección de Proteinas Principales ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Proteinas Principales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  // Botón para añadir nueva sección
                  FilledButton(
                    onPressed: _agregarProteina,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.add),
                        SizedBox(width: 8),
                        Text('Agregar nueva proteína'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ...List.generate(_principalProtein.length, (sectionIndex) {
                final protein = _principalProtein[sectionIndex];
                return Card(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //* Nombre de la proteina
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(
                              width: size.width * 0.5,
                              child: InfoLabel(
                                label: 'Nombre de la proteína',
                                child: TextFormBox(
                                  keyboardType: TextInputType.text,
                                  controller: protein.proteinController,
                                  placeholder: 'Ej: Carne, Pollo, Pescado',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            //* Botón para eliminar sección
                            IconButton(
                              onPressed: () => _eliminarProteina(sectionIndex),
                              icon: Icon(
                                FluentIcons.delete,
                                color: Colors.white,
                                ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: InfoLabel(
                                label: 'Costo por kg',
                                child: TextFormBox(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  controller: protein.buyWeightController,
                                  placeholder: '1\$',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) {

                                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                                    // 2. Reemplazamos la coma por punto para poder validarlo como número
                                    final cleanValue = v.replaceAll(',', '.');
                                    final number = double.tryParse(cleanValue);

                                    if (number == null) return 'Formato incorrecto';
                                    if (number >= 60) return 'Margen demasiado alto';

                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: InfoLabel(
                                label: 'Cantidad de Kg comprados', 
                                child: TextFormBox(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  controller: protein.buyKgWeightController,
                                  placeholder: 'Ej: 5',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) {

                                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                                    // 2. Reemplazamos la coma por punto para poder validarlo como número
                                    final cleanValue = v.replaceAll(',', '.');
                                    final number = double.tryParse(cleanValue);

                                    if (number == null) return 'Formato incorrecto';
                                    if (number >= 60) return 'Margen demasiado alto';

                                    return null;
                                  },
                                )
                              )
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: InfoLabel(
                                label: 'Porcentaje de merma',
                                child: TextFormBox(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  controller: protein.shrinkagePercentageController,
                                  placeholder: 'Ej: 10%',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) {

                                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                                    // 2. Reemplazamos la coma por punto para poder validarlo como número
                                    final cleanValue = v.replaceAll(',', '.');
                                    final number = double.tryParse(cleanValue);

                                    if (number == null) return 'Formato incorrecto';
                                    if (number >= 60) return 'Margen demasiado alto';

                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: InfoLabel(
                                label: 'Peso por porción',
                                child: TextFormBox(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  controller: protein.weightPortionController,
                                  placeholder: 'Ej: 0.25',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) {

                                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                                    // 2. Reemplazamos la coma por punto para poder validarlo como número
                                    final cleanValue = v.replaceAll(',', '.');
                                    final number = double.tryParse(cleanValue);

                                    if (number == null) return 'Formato incorrecto';
                                    if (number >= 60) return 'Margen demasiado alto';

                                    return null;
                                  },
                                ),
                              )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              Divider(
                size: size.width,
                style: DividerThemeData(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.grey[50]),
                    ),
                  )
                ),
              ),

              const SizedBox(height: 22),

              //* ==================== Sección de ingredientes adicionales (dinámica) ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ingredientes Adicionales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  // Botón para añadir nueva sección
                  FilledButton(
                    onPressed: _agregarSeccion,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.add),
                        SizedBox(width: 8),
                        Text('Agregar nueva sección'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              //* ==================== LISTA DE SECCIONES (cada una en un Card) ===
              ...List.generate(_sections.length, (sectionIndex) {
                final section = _sections[sectionIndex];

                return Card(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        //* Nombre de la sección
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(
                              width: size.width * 0.5,
                              child: InfoLabel(
                                label: 'Nombre de la sección',
                                child: TextFormBox(
                                  controller: section.nameController,
                                  placeholder: 'Ej: Salsa especial',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            //* Botón para eliminar sección
                            IconButton(
                              onPressed: () => _eliminarSeccion(sectionIndex),
                              icon: Icon(
                                FluentIcons.delete,
                                color: Colors.white,
                                ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        //* Header de Items + botón añadir item
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Ingredientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Button(
                              onPressed: () => _agregarItem(sectionIndex),
                              style: ButtonStyle(
                                elevation: WidgetStateProperty.all(1),
                                
                              ),
                              child: const Row(
                                children: [
                                  Icon(FluentIcons.add), 
                                  SizedBox(width: 6), 
                                  Text('Añadir ingrediente')],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // === ITEMS DINÁMICOS (en filas de 3 columnas) ===
                        if (section.items.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              spacing: 8,
                              children: [
                                WindowsIcon(
                                    FluentIcons.add_in,
                                    size: 50,
                                    color: Colors.grey[50],
                                  ),
                                Text('Aún no hay ingredientes. Pulsa + Añadir ingrediente',)
                              ],
                            ),
                          )
                        else
                          ...List.generate(section.items.length, (itemIndex) {
                            final item = section.items[itemIndex];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre del item
                                  Expanded(
                                    flex: 3,
                                    child: TextFormBox(
                                      controller: item.nameController,
                                      placeholder: 'Nombre del ingrediente',
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Precio por kg
                                  Expanded(
                                    flex: 2,
                                    child: TextFormBox(
                                      controller: item.pkgCostController,
                                      placeholder: 'Precio',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (v) {

                                        if (v == null || v.trim().isEmpty) return 'Obligatorio';
                                        // 2. Reemplazamos la coma por punto para poder validarlo como número
                                        final cleanValue = v.replaceAll(',', '.');
                                        final number = double.tryParse(cleanValue);

                                        if (number == null) return 'Formato incorrecto';
                                        if (number >= 60) return 'Margen demasiado alto';

                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Cantidad (kg)
                                  Expanded(
                                    flex: 2,
                                    child: TextFormBox(
                                      controller: item.countController,
                                      placeholder: 'Cantidad usada (kg)',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (v) {

                                        if (v == null || v.trim().isEmpty) return 'Obligatorio';
                                        // 2. Reemplazamos la coma por punto para poder validarlo como número
                                        final cleanValue = v.replaceAll(',', '.');
                                        final number = double.tryParse(cleanValue);

                                        if (number == null) return 'Formato incorrecto';
                                        if (number >= 60) return 'Margen demasiado alto';

                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Botón eliminar item
                                  IconButton(
                                    icon: Icon(FluentIcons.delete, color: Colors.red),
                                    onPressed: () => _eliminarItem(sectionIndex, itemIndex),
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              Divider(
                size: size.width,
                style: DividerThemeData(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.grey[50]),
                    ),
                  )
                ),
              ),

              const SizedBox(height: 24),

              //* ================ Seccion final 
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: 'Costo por unidad de pan',
                      child: TextFormBox(
                        controller: _breadUnitCostController,
                        placeholder: 'Ej: 1.50',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) {

                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          // 2. Reemplazamos la coma por punto para poder validarlo como número
                          final cleanValue = v.replaceAll(',', '.');
                          final number = double.tryParse(cleanValue);

                          if (number == null) return 'Formato incorrecto';
                          if (number >= 60) return 'Margen demasiado alto';

                          return null;
                        },
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: 'Costo por unidad de empaque',
                      child: TextFormBox(
                        controller: _packagingUnit,
                        placeholder: 'Ej: 0.50',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) {

                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          // 2. Reemplazamos la coma por punto para poder validarlo como número
                          final cleanValue = v.replaceAll(',', '.');
                          final number = double.tryParse(cleanValue);

                          if (number == null) return 'Formato incorrecto';
                          if (number >= 60) return 'Margen demasiado alto';

                          return null;
                        },
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: 'Costo de operación',
                      child: TextFormBox(
                        controller: _operationCost,
                        placeholder: 'Ej: 0.50',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) {

                          if (v == null || v.trim().isEmpty) return 'Obligatorio';
                          // 2. Reemplazamos la coma por punto para poder validarlo como número
                          final cleanValue = v.replaceAll(',', '.');
                          final number = double.tryParse(cleanValue);

                          if (number == null) return 'Formato incorrecto';
                          if (number >= 60) return 'Margen demasiado alto';

                          return null;
                        },
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: 'Margen deseado',
                      child: TextFormBox(
                        controller: _desiredProfitPercentage,
                        placeholder: 'Ej: 10%, 20%...',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) {

                          if (v == null || v.trim().isEmpty) return 'Obligatorio';

                          // 2. Reemplazamos la coma por punto para poder validarlo como número
                          final cleanValue = v.replaceAll(',', '.');
                          final number = double.tryParse(cleanValue);

                          if (number == null) return 'Formato incorrecto';
                          if (number >= 60) return 'Margen demasiado alto';

                          return null;
                        },
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 4,
                children: [
                  //* Boton para calcular
                  SizedBox(
                    width: size.width * 0.35,
                    child: FilledButton(
                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green)),
                      onPressed: () async {

                        //* Validar form
                        if (_formKey.currentState!.validate()) {

                          //* obtener gastos fijos para verificar si hay o no
                          if (fixedCostProvider.getFixedCost() == 0) {
                            return await displayInfoBar(context, builder: (context, close) {
                              return InfoBar(
                                title: const Text('No hay gastos fijos configurados'),
                                content: Text('Diríjase a la sección de gastos fijos en el inicio para configurarlos'),
                                action: Icon(
                                  FluentIcons.check_mark, color: Colors.green, size: 20
                                  // onPressed: () => Navigator.pop(context),
                                ),
                                severity: InfoBarSeverity.error,
                              );
                            });
                          }

                          final additionalIngredients = buildAdditionalIngredientsModel();
                          final principalProteins = buildPrincipalProteinModel();

                          setState(() {
                            fixedCostsAndMargin = FixedCostsAndMarginAd(
                              breadUnit: double.tryParse(_breadUnitCostController.text.trim()) ?? 0,
                              packagingUnit: double.tryParse(_packagingUnit.text.trim()) ?? 0,
                              operatingCost: double.tryParse(_operationCost.text.trim()) ?? 0,
                              desiredProfitPercentage: double.tryParse(_desiredProfitPercentage.text.trim()) ?? 0
                            );

                            fixedCostsAndMarginModel = FixedCostsAndMargin(
                              breadUnit: double.tryParse(_breadUnitCostController.text.trim()) ?? 0,
                              packagingUnit: double.tryParse(_packagingUnit.text.trim()) ?? 0,
                              operatingCost: double.tryParse(_operationCost.text.trim()) ?? 0,
                              desiredProfitPercentage: double.tryParse(_desiredProfitPercentage.text.trim()) ?? 0
                            );
                          });

                          final recipeModel = RecipeModel(
                            name: _nameController.text.trim(),
                            principalProtein: principalProteins,
                            additionalsingredients: additionalIngredients,
                            fixedCostsAndMargin: fixedCostsAndMargin
                          );

                          final calculator = RecipeCalculator(
                            monthlyFixedExpenses: fixedCostProvider.getFixedCost(),
                            usdExchangeRate: exchangeRateProvider.getExchangeRate()
                          );

                          debugPrint('Costo por Kg de la primera proteína: ${principalProteins[0].buyWeight}');
                          debugPrint('cantidad de Kg comprados de la primera proteína: ${principalProteins[0].buyKgWeight}');

                          RecipeCalculation calculatedCost = calculator.calculateRecipeCosts(
                            RecipeRequestModel(
                              recipeName: recipeModel.name,
                              mainIngredients: principalProteins.map((item) => MainIngredient(
                                name: item.name,
                                purchaseWeightKg: item.buyKgWeight,
                                purchasePricePerKg: item.buyWeight,
                                wastePercentage: item.shrikagepercentage,
                                weightPerPortionKg: item.weightPortionKg
                              )).toList(),
                              additionalSectionsRequest: additionalIngredients.sections.map((item) => AdditionalSectionRequest(
                                name: item.name,
                                items: item.items.map((item) => Item(
                                  name: item.name,
                                  pricePerKg: item.kgCost.toDouble(),
                                  quantityKg: item.count.toDouble()
                                )).toList()
                              )).toList(),
                              fixedCostsAndMargin: fixedCostsAndMarginModel
                            )
                          );
                                      
                          if (mounted) {
                            
                            setState(() {
                              showCalculatedCost = !showCalculatedCost;
                              recipe = calculatedCost;
                            });

                            await ShowContentDialogDynamic.showContentDialogDynamic(
                              context,
                              ContentDialog(
                                constraints: BoxConstraints.expand(width: size.width * 0.5, height: size.height * 0.8),
                                title: Column(
                                  spacing: 8,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(WindowsIcons.emoji_tab_food_plants, size: 20),
                                        const SizedBox(width: 5),
                                        Text(
                                          _nameController.text.toUpperCase(),
                                          style: FluentTheme.of(context).typography.subtitle,
                                        ),
                                      ]
                                    ),
                              
                                    RichText(
                                      text: TextSpan(
                                        text: 'Tasa de cambio: ',
                                        style: FluentTheme.of(context).typography.bodyStrong,
                                        children: [
                                          TextSpan(
                                            text: "${calculatedCost.exchangeRate.toString()} Bs.",
                                            style: FluentTheme.of(context).typography.body?.copyWith(
                                              color: Colors.green,
                                            ),
                                          )
                                        ]
                                      ),
                                    ),
                              
                                  ],
                                ) ,
                                content: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                  
                                      const Divider(),
                                  
                                      Text(
                                        'Ingredientes principales',
                                        style: FluentTheme.of(context).typography.subtitle,
                                      ),
                                  
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: calculatedCost.mainIngredientResults.length,
                                        itemBuilder: (context, index) {
                                  
                                          final item = calculatedCost.mainIngredientResults[index];
                                  
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              // color: Colors.grey.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.grey, width: 2)
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                    text: TextSpan(
                                                    text: 'Proteina: ',
                                                    style: FluentTheme.of(context).typography.body,
                                                    children: [
                                                      TextSpan(
                                                        text: item.name,
                                                        style: FluentTheme.of(context).typography.bodyStrong,
                                                      )
                                                    ]
                                                  )),
                                            
                                                  Text('Cálculo de merma:', style: FluentTheme.of(context).typography.bodyStrong,),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'Peso inicial: ',
                                                      style: FluentTheme.of(context).typography.body,
                                                      children: [
                                                        TextSpan(
                                                          text: '${item.wasteCalculations.initialWeightKg.toString()} Kg',
                                                          style: FluentTheme.of(context).typography.bodyStrong,
                                                        )
                                                      ]
                                                    ),
                                                  ),
                                            
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '% merma: ',
                                                      style: FluentTheme.of(context).typography.body,
                                                      children: [
                                                        TextSpan(
                                                          text: '${item.wasteCalculations.wastePercentage.toString()} %',
                                                          style: FluentTheme.of(context).typography.bodyStrong,
                                                        )
                                                      ]
                                                    ),
                                                  ),
                                            
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'Peso útil: ',
                                                      style: FluentTheme.of(context).typography.body,
                                                      children: [
                                                        TextSpan(
                                                          text: '${item.wasteCalculations.usableWeightKg.toString()} Kg',
                                                          style: FluentTheme.of(context).typography.bodyStrong,
                                                        )
                                                      ]
                                                    ),
                                                  ),
                                            
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'Precio Real: ',
                                                      style: FluentTheme.of(context).typography.body,
                                                      children: [
                                                        TextSpan(
                                                          text: item.wasteCalculations.realPricePerKg.toString(),
                                                          style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                            color: Colors.green,
                                                          ),
                                                        )
                                                      ]
                                                    ),
                                                  ),
                                            
                                                  //* =============== Porció utilizada
                                            
                                                  Text(
                                                    'Porción utilizada',
                                                    style: FluentTheme.of(context).typography.bodyStrong,
                                                  ),
                                            
                                                  // RichText(
                                                  //   text: TextSpan(
                                                  //     text: 'Cantidad de porcines posibles: ',
                                                  //     style: FluentTheme.of(context).typography.bodyStrong,
                                                  //     children: [
                                                  //       TextSpan(
                                                  //         text: "${item.portion.weightUsedKg.toInt().toString()} porciones",
                                                  //         style: FluentTheme.of(context).typography.body,
                                                  //       )
                                                  //     ]
                                                  //   ),
                                                  // ),
                                            
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'Costo Porción: ',
                                                      style: FluentTheme.of(context).typography.body,
                                                      children: [
                                                        TextSpan(
                                                          text: item.portion.cost.toString(),
                                                          style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                            color: Colors.green,
                                                          ),
                                                        )
                                                      ]
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        }
                                      ),
                                  
                                      //* =============== RESUMEN DE COSTOS
                                  
                                      const Divider(),
                                  
                                      Text(
                                        'Resumen de costos',
                                        style: FluentTheme.of(context).typography.subtitle,
                                      ),
                                  
                                      RichText(
                                        text: TextSpan(
                                          text: 'Costo total ingredientes: ',
                                          style: FluentTheme.of(context).typography.body,
                                          children: [
                                            TextSpan(
                                              text: calculatedCost.economicSummary.totalIngredientsCost.toString(),
                                              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                color: Colors.green,
                                              ),
                                            )
                                          ]
                                        ),
                                      ),
                                  
                                      RichText(
                                        text: TextSpan(
                                          text: 'Ganancia esperada: ',
                                          style: FluentTheme.of(context).typography.body,
                                          children: [
                                            TextSpan(
                                              text: calculatedCost.economicSummary.expectedProfit.toString(),
                                              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                color: Colors.green,
                                              ),
                                            )
                                          ]
                                        ),
                                      ),
                                  
                                      RichText(
                                        text: TextSpan(
                                          text: 'Gastos Fijos por Unidad: ',
                                          style: FluentTheme.of(context).typography.body,
                                          children: [
                                            TextSpan(
                                              text: calculatedCost.economicSummary.unitFixedExpenses.toString(),
                                              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                color: Colors.green,
                                              ),
                                            )
                                          ]
                                        ),
                                      ),
                                  
                                      const SizedBox(height: 8),
                                      const Divider(),
                                  
                                      //* BUSSINES MAINTENCE
                                      Text(
                                        'Mantenimiento del negocio',
                                        style: FluentTheme.of(context).typography.subtitle,
                                      ),
                                  
                                      RichText(
                                        text: TextSpan(
                                          text: 'Gastos generales: ',
                                          style: FluentTheme.of(context).typography.body,
                                          children: [
                                            TextSpan(
                                              text: calculatedCost.businessMaintenance.monthlyFixedExpenses.toString(),
                                              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                color: Colors.green,
                                              ),
                                            )
                                          ]
                                        ),
                                      ),
                                  
                                      RichText(
                                        text: TextSpan(
                                          text: 'Ganancia: ',
                                          style: FluentTheme.of(context).typography.body,
                                          children: [
                                            TextSpan(
                                              text: calculatedCost.businessMaintenance.netProfitPerUnit.toString(),
                                              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                color: Colors.green,
                                              ),
                                            )
                                          ]
                                        ),
                                      ),
                                  
                                      RichText(
                                        text: TextSpan(
                                          text: 'Punto de equilibrio: ',
                                          style: FluentTheme.of(context).typography.body,
                                          children: [
                                            TextSpan(
                                              text: calculatedCost.businessMaintenance.unitsForBreakEven.toString(),
                                              style: FluentTheme.of(context).typography.bodyStrong,
                                            )
                                          ]
                                        ),
                                      ),
                                  
                                      const SizedBox(height: 8),
                                      const Divider(),
                                  
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total: ",
                                              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              calculatedCost.economicSummary.suggestedSalesPrice.toString(),
                                              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                                                fontSize: 18,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                    ]),
                                ),
                                actions: [
                                  FilledButton(
                                    child: const Text('Guardar receta'),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                              
                                        final additionalIngredients = buildAdditionalIngredientsModel();
                                        final additionalSectionCost = buildAdditionalSectionCostModel(calculatedCost);
                                        final principalProteinCost = buildPrincipalProteinCostModel(calculatedCost);
                                        final principalProteins = buildPrincipalProteinModel();
                                        
                                        //* Preparo el modelo que guardara la receta en la caja de recipeBox
                                        final recipeModel = RecipeModel(
                                          name: _nameController.text.trim(),
                                          principalProtein: principalProteins,
                                          additionalsingredients: additionalIngredients,
                                          fixedCostsAndMargin: fixedCostsAndMargin,
                                          recipeCostModel: RecipeCostModel(
                                            recipeName: _nameController.text.trim(),
                                            exchangeRate: calculatedCost.exchangeRate,
                                            mainIngredients: principalProteinCost,
                                            additionalSections: additionalSectionCost,
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
                                        await recipeBox.add(recipeModel);
                              
                                        //* Si esta montado el widget muestra el snackbar
                                        if (mounted) {
                              
                                          await displayInfoBar(context, builder: (context, close) {
                                            return InfoBar(
                                              title: const Text('Receta guardada'),
                                              content: Text(
                                                  'Se crearon ${_sections.length} secciones'),
                                              action: IconButton(
                                                icon: const WindowsIcon(WindowsIcons.check_mark),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              severity: InfoBarSeverity.success,
                                            );
                                          });
                              
                                          // Navigator.pop(context);
                                        } else {
                              
                                          LoggerService.write('No se pudo guardar la receta');
                              
                                          //* Mensaje de error si no esta montado el widget
                                          await displayInfoBar(context, builder: (context, close) {
                                            return InfoBar(
                                              title: const Text('Ha ocurrido un error inesperado'),
                                              content: const Text('No se pudo guardar la receta'),
                                              action: IconButton(
                                                icon: const WindowsIcon(WindowsIcons.error),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              severity: InfoBarSeverity.error,
                                            );
                                          });
                                        }
                                      }
                                    },
                                  ),
                              
                                  Button(
                                    child: const Text('Cerrar'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ])
                              );
                          }
                          
                        }
                      },
                      child: Text('Calcular costos'),
                    ),
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