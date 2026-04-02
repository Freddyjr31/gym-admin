class RecipeCalculation {
  final String? recipeName;
  final double exchangeRate;
  final List<MainIngredientResult> mainIngredientResults;
  final List<AdditionalSection> additionalSections;
  final EconomicSummary economicSummary;
  final BusinessMaintenance businessMaintenance;

  RecipeCalculation({
    this.recipeName,
    required this.exchangeRate,
    required this.mainIngredientResults,
    required this.additionalSections,
    required this.economicSummary,
    required this.businessMaintenance,
  });

  factory RecipeCalculation.fromJson(Map<String, dynamic> json) => RecipeCalculation(
    recipeName: json['recipeName'],
    exchangeRate: json['exchangeRate'].toDouble(),
    mainIngredientResults: List<MainIngredientResult>.from(json['mainIngredientResults'].map((x) => MainIngredientResult.fromJson(x))),
    additionalSections: List<AdditionalSection>.from(json['additionalSections'].map((x) => AdditionalSection.fromJson(x))),
    economicSummary: EconomicSummary.fromJson(json['economicSummary']),
    businessMaintenance: BusinessMaintenance.fromJson(json['businessMaintenance']),
  );
}

class MainIngredientResult {
  final String name;
  final WasteCalculations wasteCalculations;
  final Portion portion;

  MainIngredientResult({required this.name, required this.wasteCalculations, required this.portion});

  factory MainIngredientResult.fromJson(Map<String, dynamic> json) => MainIngredientResult(
    name: json['name'],
    wasteCalculations: WasteCalculations.fromJson(json['wasteCalculations']),
    portion: Portion.fromJson(json['portion']),
  );
}

class Portion {
  final double weightUsedKg;
  final dynamic cost;

  Portion({
    required this.weightUsedKg,
    required this.cost,
  });

  factory Portion.fromJson(Map<String, dynamic> json) => Portion(
    // Conversión segura a double por si el JSON trae un entero
    weightUsedKg: (json['weightUsedKg'] as num).toDouble(),
    cost: json['cost'] ?? '0 \$.',
  );

  Map<String, dynamic> toJson() => {
    'weightUsedKg': weightUsedKg,
    'cost': cost,
  };
}

class WasteCalculations {
  final double initialWeightKg;
  final double wastePercentage;
  final double usableWeightKg;
  final dynamic
   realPricePerKg;

  WasteCalculations({
    required this.initialWeightKg,
    required this.wastePercentage,
    required this.usableWeightKg,
    required this.realPricePerKg,
  });

  factory WasteCalculations.fromJson(Map<String, dynamic> json) => WasteCalculations(
    initialWeightKg: json['initialWeightKg'].toDouble(),
    wastePercentage: json['wastePercentage'].toDouble(),
    usableWeightKg: json['usableWeightKg'].toDouble(),
    realPricePerKg: json['realPricePerKg'],
  );
}

class AdditionalSection {
  final String? sectionName;
  final List<AdditionalItem> items;
  final String sectionTotal;

  AdditionalSection({this.sectionName, required this.items, required this.sectionTotal});

  factory AdditionalSection.fromJson(Map<String, dynamic> json) => AdditionalSection(
    sectionName: json['sectionName'],
    items: List<AdditionalItem>.from(json['items'].map((x) => AdditionalItem.fromJson(x))),
    sectionTotal: json['sectionTotal'],
  );
}

class AdditionalItem {
  final String name;
  final double quantityKg;
  final dynamic pricePerKg;
  final dynamic subtotal;

  AdditionalItem({required this.name, required this.quantityKg, required this.pricePerKg, required this.subtotal});

  factory AdditionalItem.fromJson(Map<String, dynamic> json) => AdditionalItem(
    name: json['name'],
    quantityKg: json['quantityKg'].toDouble(),
    pricePerKg: json['pricePerKg'],
    subtotal: json['subtotal'],
  );
}

class EconomicSummary {
  final String totalIngredientsCost;
  final String expectedProfit;
  final String unitFixedExpenses;
  final String suggestedSalesPrice;

  EconomicSummary({
    required this.totalIngredientsCost,
    required this.expectedProfit,
    required this.unitFixedExpenses,
    required this.suggestedSalesPrice,
  });

  factory EconomicSummary.fromJson(Map<String, dynamic> json) => EconomicSummary(
    totalIngredientsCost: json['totalIngredientsCost'] ?? '0 \$',
    expectedProfit: json['expectedProfit'] ?? '0 \$',
    unitFixedExpenses: json['unitFixedExpenses'] ?? '0 \$',
    suggestedSalesPrice: json['suggestedSalesPrice'] ?? '0 \$',
  );
}

class BusinessMaintenance {
  final String monthlyFixedExpenses;
  final String netProfitPerUnit;
  final int unitsForBreakEven;

  BusinessMaintenance({
    required this.monthlyFixedExpenses,
    required this.netProfitPerUnit,
    required this.unitsForBreakEven,
  });

  factory BusinessMaintenance.fromJson(Map<String, dynamic> json) => BusinessMaintenance(
    monthlyFixedExpenses: json['monthlyFixedExpenses'] ?? '0 \$',
    netProfitPerUnit: json['netProfitPerUnit'] ?? '0 \$',
    unitsForBreakEven: json['unitsForBreakEven'] is int 
        ? json['unitsForBreakEven'] 
        : (json['unitsForBreakEven'] as double).toInt(),
  );
}