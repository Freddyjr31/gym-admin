import 'package:fluent_ui/fluent_ui.dart';
import 'package:gym_admin/core/helpers/show_content_dialog_dynamic.dart';
import 'package:gym_admin/data/datasource/Local/recipe_adapter.dart';
import 'package:gym_admin/data/datasource/Local/recipe_cost_adapter.dart';
import 'package:gym_admin/data/datasource/Local/reipe.dart';
import 'package:gym_admin/data/models/calculated_cost_model.dart';
import 'package:gym_admin/data/models/data_to_calculated.dart';
import 'package:gym_admin/presentation/providers/exchange_rate_provider.dart';
import 'package:gym_admin/presentation/providers/fixed_cost_provider.dart';
import 'package:gym_admin/presentation/providers/recipe_calculator.dart';
import 'package:provider/provider.dart';

//* ==================== MODELOS LOCALES PARA EL FORMULARIO ITEMS ====================
class SectionState {
  final TextEditingController nameController;
  final List<ItemState> items;

  SectionState({String initialName = ''})
      : nameController = TextEditingController(text: initialName),
        items = [];
}

class ItemState {
  final TextEditingController nameController;
  final TextEditingController pkgCostController; // precio por kg (double)
  final TextEditingController countController;   // cantidad (int)

  ItemState()
      : nameController = TextEditingController(),
        pkgCostController = TextEditingController(),
        countController = TextEditingController();
}

//* ==================== FIN MODELOS LOCALES PARA EL FORMULARIO PROTEINA PRINCIPAL ====================
class PrincipalProtein {

  final TextEditingController _shrinkagePercentageController;
  final TextEditingController _proteinController;
  final TextEditingController _buyWeightController;
  final TextEditingController _buyKgWeightController;
  final TextEditingController _weightPortionController;

  PrincipalProtein({
    String initialName = ''
  }) : _proteinController = TextEditingController(text: initialName),
        _buyWeightController = TextEditingController(),
        _buyKgWeightController = TextEditingController(),
        _shrinkagePercentageController = TextEditingController(),
        _weightPortionController = TextEditingController();
}


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
  // late Map<String, dynamic> recipe;
  late RecipeCalculation recipe;

  @override
  void initState() {
    super.initState();
    _principalProtein.add(PrincipalProtein(initialName: "Pollo, Carne, Pescado..."));
    // Por defecto: 2 secciones como pediste
    _sections.add(SectionState(initialName: 'Marinado'));
    _sections.add(SectionState(initialName: 'Relleno'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breadUnitCostController.dispose();
    _packagingUnit.dispose();
    _operationCost.dispose();
    _desiredProfitPercentage.dispose();

    for (var section in _sections) {
      section.nameController.dispose();
      for (var item in section.items) {
        item.nameController.dispose();
        item.pkgCostController.dispose();
        item.countController.dispose();
      }
    }

    for (var principalProtein in _principalProtein) {
      principalProtein._shrinkagePercentageController.dispose();
      principalProtein._buyWeightController.dispose();
      principalProtein._buyKgWeightController.dispose();
      principalProtein._weightPortionController.dispose();
    }
    
    super.dispose();
  }

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
  void _agregarSeccion() {
    setState(() {
      _sections.add(SectionState());
    });
  }

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

  void _agregarItem(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].items.add(ItemState());
    });
  }

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
        return ItemsSections(
          name: item.nameController.text.trim(),
          kgCost: double.tryParse(item.pkgCostController.text) ?? 0.0,
          count: int.tryParse(item.countController.text) ?? 0,
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
        name: protein._proteinController.text.trim(),
        buyWeight: double.tryParse(protein._buyWeightController.text.trim()) ?? 0.0, 
        buyKgWeight: double.tryParse(protein._buyKgWeightController.text.trim()) ?? 0.0, 
        shrikagepercentage: double.tryParse(protein._shrinkagePercentageController.text.trim()) ?? 0.0, 
        weightPortionKg: double.tryParse(protein._weightPortionController.text.trim()) ?? 0.0,
      );
    }).toList();

    return proteins;
    
  }

  // /// Función para construir el modelo de proteinas adicionales
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
                                  controller: protein._proteinController,
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
                                  controller: protein._buyWeightController,
                                  placeholder: '1kg',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: InfoLabel(
                                label: 'Kg comprados', 
                                child: TextFormBox(
                                  controller: protein._buyKgWeightController,
                                  placeholder: '1',
                                  validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
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
                                  controller: protein._shrinkagePercentageController,
                                  placeholder: '10%',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: InfoLabel(
                                label: 'Peso por porción',
                                child: TextFormBox(
                                  controller: protein._weightPortionController,
                                  placeholder: '0.25',
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
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
                                      placeholder: 'Precio/kg',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Cantidad (kg)
                                  Expanded(
                                    flex: 2,
                                    child: TextFormBox(
                                      controller: item.countController,
                                      placeholder: 'Cantidad (kg)',
                                      keyboardType: TextInputType.number,
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
                        placeholder: '1.50',
                        validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: 'Costo por unidad de empaque',
                      child: TextFormBox(
                        controller: _packagingUnit,
                        placeholder: '0.50',
                        validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
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
                        placeholder: '0.50',
                        validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: 'Margen deseado',
                      child: TextFormBox(
                        controller: _desiredProfitPercentage,
                        placeholder: '10%',
                        validator: (v) => v!.trim().isEmpty ? 'Obligatorio' : null,
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
                        if (_formKey.currentState!.validate()) {

                          final additionalIngredients = buildAdditionalIngredientsModel();
                          final principalProteins = buildPrincipalProteinModel();

                          final recipeModel = RecipeModel(
                            name: _nameController.text.trim(),
                            principalProtein: principalProteins,
                            additionalsingredients: additionalIngredients
                          );

                          final calculator = RecipeCalculator(
                            monthlyFixedExpenses: fixedCostProvider.getFixedCost(),
                            usdExchangeRate: exchangeRateProvider.getExchangeRate()
                          );

                          RecipeCalculation calculatedCost = calculator.calculateRecipeCosts(
                            RecipeRequestModel(
                              recipeName: recipeModel.name,
                              mainIngredients: principalProteins.map((item) => MainIngredient(
                                name: item.name,
                                purchaseWeightKg: item.buyWeight,
                                purchasePricePerKg: item.buyKgWeight,
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
                              fixedCostsAndMargin: FixedCostsAndMargin(
                                breadUnit: double.tryParse(_breadUnitCostController.text.trim()) ?? 0,
                                packagingUnit: double.tryParse(_packagingUnit.text.trim()) ?? 0,
                                operatingCost: double.tryParse(_operationCost.text.trim()) ?? 0,
                                desiredProfitPercentage: double.tryParse(_desiredProfitPercentage.text.trim()) ?? 0
                              )
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
                                title: Column(
                                  spacing: 4,
                                  mainAxisSize: MainAxisSize.min,
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
                                            style: FluentTheme.of(context).typography.body,
                                          )
                                        ]
                                      ),
                                    ),

                                  ],
                                ) ,
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              RichText(
                                                  text: TextSpan(
                                                  text: 'Proteina: ',
                                                  style: FluentTheme.of(context).typography.bodyStrong,
                                                  children: [
                                                    TextSpan(
                                                      text: item.name,
                                                      style: FluentTheme.of(context).typography.bodyStrong,
                                                    )
                                                  ]
                                                )),
                                          
                                                Text('Cálculo de merma:'),
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Peso inicial: ',
                                                    style: FluentTheme.of(context).typography.bodyStrong,
                                                    children: [
                                                      TextSpan(
                                                        text: '${item.wasteCalculations.initialWeightKg.toString()} Kg',
                                                        style: FluentTheme.of(context).typography.body,
                                                      )
                                                    ]
                                                  ),
                                                ),
                                          
                                                RichText(
                                                  text: TextSpan(
                                                    text: '% merma: ',
                                                    style: FluentTheme.of(context).typography.bodyStrong,
                                                    children: [
                                                      TextSpan(
                                                        text: '${item.wasteCalculations.wastePercentage.toString()} %',
                                                        style: FluentTheme.of(context).typography.body,
                                                      )
                                                    ]
                                                  ),
                                                ),
                                          
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Peso útil: ',
                                                    style: FluentTheme.of(context).typography.bodyStrong,
                                                    children: [
                                                      TextSpan(
                                                        text: '${item.wasteCalculations.usableWeightKg.toString()} Kg',
                                                        style: FluentTheme.of(context).typography.body,
                                                      )
                                                    ]
                                                  ),
                                                ),
                                          
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Precio Real: ',
                                                    style: FluentTheme.of(context).typography.bodyStrong,
                                                    children: [
                                                      TextSpan(
                                                        text: item.wasteCalculations.realPricePerKg.toString(),
                                                        style: FluentTheme.of(context).typography.body,
                                                      )
                                                    ]
                                                  ),
                                                ),
                                          
                                                //* =============== Porció utilizada
                                          
                                                Text(
                                                  'Porción utilizada',
                                                  style: FluentTheme.of(context).typography.bodyStrong,
                                                ),
                                          
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Cantidad: ',
                                                    style: FluentTheme.of(context).typography.bodyStrong,
                                                    children: [
                                                      TextSpan(
                                                        text: item.portion.weightUsedKg.toString(),
                                                        style: FluentTheme.of(context).typography.body,
                                                      )
                                                    ]
                                                  ),
                                                ),
                                          
                                                RichText(
                                                  text: TextSpan(
                                                    text: 'Costo Porción: ',
                                                    style: FluentTheme.of(context).typography.bodyStrong,
                                                    children: [
                                                      TextSpan(
                                                        text: item.portion.cost.toString(),
                                                        style: FluentTheme.of(context).typography.body,
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
                                        style: FluentTheme.of(context).typography.bodyStrong,
                                        children: [
                                          TextSpan(
                                            text: calculatedCost.economicSummary.totalIngredientsCost.toString(),
                                            style: FluentTheme.of(context).typography.body,
                                          )
                                        ]
                                      ),
                                    ),

                                    RichText(
                                      text: TextSpan(
                                        text: 'Ganancia esperada: ',
                                        style: FluentTheme.of(context).typography.bodyStrong,
                                        children: [
                                          TextSpan(
                                            text: calculatedCost.economicSummary.expectedProfit.toString(),
                                            style: FluentTheme.of(context).typography.body,
                                          )
                                        ]
                                      ),
                                    ),

                                    RichText(
                                      text: TextSpan(
                                        text: 'Costo total de la receta: ',
                                        style: FluentTheme.of(context).typography.bodyStrong,
                                        children: [
                                          TextSpan(
                                            text: calculatedCost.economicSummary.suggestedSalesPrice.toString(),
                                            style: FluentTheme.of(context).typography.body,
                                          )
                                        ]
                                      ),
                                    ),

                                    RichText(
                                      text: TextSpan(
                                        text: 'Gastos Fijos por Unidad: ',
                                        style: FluentTheme.of(context).typography.bodyStrong,
                                        children: [
                                          TextSpan(
                                            text: calculatedCost.economicSummary.unitFixedExpenses.toString(),
                                            style: FluentTheme.of(context).typography.body,
                                          )
                                        ]
                                      ),
                                    ),
                                    
                                  ]),
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
                                            )
                                          )
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

                                          Navigator.pop(context);
                                        } else {

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