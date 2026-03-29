import 'package:hive/hive.dart';

part 'recipe_cost_adapter.g.dart';

@HiveType(typeId: 10)
class RecipeCostModel extends HiveObject {
  @HiveField(0)
  final String? recipeName;

  @HiveField(1)
  final double exchangeRate;

  @HiveField(2)
  final List<MainIngredientCost> mainIngredients;

  @HiveField(3)
  final List<AdditionalSectionCost> additionalSections;

  @HiveField(4)
  final EconomicSummaryCost economicSummary;

  @HiveField(5)
  final BusinessMaintenanceCost businessMaintenance;

  RecipeCostModel({
    required this.recipeName,
    required this.exchangeRate,
    required this.mainIngredients,
    required this.additionalSections,
    required this.economicSummary,
    required this.businessMaintenance
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'recipeName': recipeName,
    'exchangeRate': exchangeRate,
    'mainIngredients': mainIngredients,
    'additionalSections': additionalSections,
    'economicSummary': economicSummary,
    'businessMaintenance': businessMaintenance,
  };

  //* JSON IMPORT
  factory RecipeCostModel.fromJson(Map<String, dynamic> json) => RecipeCostModel(
    recipeName: json['recipeName'],
    exchangeRate: json['exchangeRate'],
    mainIngredients: List<MainIngredientCost>.from(json['mainIngredients'].map((x) => MainIngredientCost.fromJson(x))),
    additionalSections: List<AdditionalSectionCost>.from(json['additionalSections'].map((x) => AdditionalSectionCost.fromJson(x))),
    economicSummary: EconomicSummaryCost.fromJson(json['economicSummary']),
    businessMaintenance: BusinessMaintenanceCost.fromJson(json['businessMaintenance']),
  );
}

@HiveType(typeId: 11)
class MainIngredientCost {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final WasteCalculationsCost wasteCalculations;

  @HiveField(2)
  final PortionCost portion;

  MainIngredientCost({
    required this.name,
    required this.wasteCalculations,
    required this.portion,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'wasteCalculations': wasteCalculations,
    'portion': portion,
  };

  //* JSON IMPORT
  factory MainIngredientCost.fromJson(Map<String, dynamic> json) => MainIngredientCost(
    name: json['name'],
    wasteCalculations: WasteCalculationsCost.fromJson(json['wasteCalculations']),
    portion: PortionCost.fromJson(json['portion']),
  );

}

@HiveType(typeId: 12)
class WasteCalculationsCost {
  @HiveField(0)
  final double initialWeightKg;

  @HiveField(1)
  final double wastePercentage;

  @HiveField(2)
  final double usableWeightKg;

  @HiveField(3)
  final String realPricePerKg;

  WasteCalculationsCost({
    required this.initialWeightKg,
    required this.wastePercentage,
    required this.usableWeightKg,
    required this.realPricePerKg,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'initialWeightKg': initialWeightKg,
    'wastePercentage': wastePercentage,
    'usableWeightKg': usableWeightKg,
    'realPricePerKg': realPricePerKg,
  };

  //* JSON IMPORT
  factory WasteCalculationsCost.fromJson(Map<String, dynamic> json) => WasteCalculationsCost(
    initialWeightKg: json['initialWeightKg'],
    wastePercentage: json['wastePercentage'],
    usableWeightKg: json['usableWeightKg'],
    realPricePerKg: json['realPricePerKg'],
  );
}

@HiveType(typeId: 13)
class PortionCost {
  @HiveField(0)
  final double weightUsedKg;

  @HiveField(1)
  final String cost;

  PortionCost({
    required this.weightUsedKg,
    required this.cost,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'weightUsedKg': weightUsedKg,
    'cost': cost,
  };

  //* JSON IMPORT
  factory PortionCost.fromJson(Map<String, dynamic> json) {
    return PortionCost(
      weightUsedKg: json['weightUsedKg'],
      cost: json['cost'],
    );
  }
}

@HiveType(typeId: 14)
class AdditionalSectionCost {
  @HiveField(0)
  final String? sectionName;

  @HiveField(1)
  final List<AdditionalItemCost> items;

  @HiveField(2)
  final String sectionTotal;

  AdditionalSectionCost({
    required this.sectionName,
    required this.items,
    required this.sectionTotal,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'sectionName': sectionName,
    'items': items,
    'sectionTotal': sectionTotal,
  };

  factory AdditionalSectionCost.fromJson(Map<String, dynamic> json) {
    return AdditionalSectionCost(
      sectionName: json['sectionName'],
      items: List<AdditionalItemCost>.from(json['items'].map((x) => AdditionalItemCost.fromJson(x))),
      sectionTotal: json['sectionTotal'],
    );
  }

}

@HiveType(typeId: 15)
class AdditionalItemCost {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double quantityKg;

  @HiveField(2)
  final String pricePerKg;

  @HiveField(3)
  final String subtotal;

  AdditionalItemCost({
    required this.name,
    required this.quantityKg,
    required this.pricePerKg,
    required this.subtotal,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'quantityKg': quantityKg,
    'pricePerKg': pricePerKg,
    'subtotal': subtotal,
  };

  //* JSON IMPORT
  factory AdditionalItemCost.fromJson(Map<String, dynamic> json) {
    return AdditionalItemCost(
      name: json['name'],
      quantityKg: json['quantityKg'],
      pricePerKg: json['pricePerKg'],
      subtotal: json['subtotal'],
    );
  }
}

@HiveType(typeId: 16)
class EconomicSummaryCost {
  @HiveField(0)
  final String totalIngredientsCost;

  @HiveField(1)
  final String expectedProfit;

  @HiveField(2)
  final String unitFixedExpenses;

  @HiveField(3)
  final String suggestedSalesPrice;

  EconomicSummaryCost({
    this.totalIngredientsCost = "0.0",
    required this.expectedProfit,
    required this.unitFixedExpenses,
    required this.suggestedSalesPrice,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'totalIngredientsCost': totalIngredientsCost,
    'expectedProfit': expectedProfit,
    'unitFixedExpenses': unitFixedExpenses,
    'suggestedSalesPrice': suggestedSalesPrice,
  };

  factory EconomicSummaryCost.fromJson(Map<String, dynamic> json) {
    return EconomicSummaryCost(
      totalIngredientsCost: json['totalIngredientsCost'],
      expectedProfit: json['expectedProfit'],
      unitFixedExpenses: json['unitFixedExpenses'],
      suggestedSalesPrice: json['suggestedSalesPrice'],
    );
  }
}

@HiveType(typeId: 17)
class BusinessMaintenanceCost {

  @HiveField(0)
  final String monthlyFixedExpenses;

  @HiveField(1)
  final String netProfitperUnit;

  @HiveField(2)
  final int unitsForBreakEven;

  BusinessMaintenanceCost({
    required this.monthlyFixedExpenses,
    required this.netProfitperUnit,
    required this.unitsForBreakEven
    });

  //* TO JSON 
  Map<String, dynamic> toJson() => {
    'monthlyFixedExpenses': monthlyFixedExpenses,
    'netProfitperUnit': netProfitperUnit,
    'unitsForBreakEven': unitsForBreakEven,
  };

  //* JSON IMPORT
  factory BusinessMaintenanceCost.fromJson(Map<String, dynamic> json) {
    return BusinessMaintenanceCost(
      monthlyFixedExpenses: json['monthlyFixedExpenses'],
      netProfitperUnit: json['netProfitperUnit'],
      unitsForBreakEven: json['unitsForBreakEven'],
    );
  }
}