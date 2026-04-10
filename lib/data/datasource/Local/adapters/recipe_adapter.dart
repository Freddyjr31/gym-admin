import 'package:cook_ledger/data/datasource/Local/adapters/recipe_cost_adapter.dart';
import 'package:hive/hive.dart';

part 'recipe_adapter.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {

  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<PrincipalProteinModel> principalProtein;

  @HiveField(2)
  final AdditionalIngredients? additionalsingredients;

  @HiveField(3)
  final RecipeCostModel? recipeCostModel;

  @HiveField(5)
  final FixedCostsAndMarginAd? fixedCostsAndMargin;

  RecipeModel({
    required this.name,
    required this.principalProtein,
    this.additionalsingredients,
    this.recipeCostModel,
    required this.fixedCostsAndMargin,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'principalProtein': principalProtein,
    'additionalsingredients': additionalsingredients,
    'recipeCostModel': recipeCostModel,
    'fixedCostsAndMargin': fixedCostsAndMargin
  };

  //* JSON IMPORT
  factory RecipeModel.fromJson(Map<String, dynamic> json) => RecipeModel(
    name: json['name'],
    principalProtein: List<PrincipalProteinModel>.from(json['principalProtein'].map((x) => PrincipalProteinModel.fromJson(x))),
    additionalsingredients: json['additionalsingredients'] != null ? AdditionalIngredients.fromJson(json['additionalsingredients']) : null,
    recipeCostModel: json['recipeCostModel'] != null ? RecipeCostModel.fromJson(json['recipeCostModel']) : null,
    fixedCostsAndMargin: json['fixedCostsAndMargin'] != null ? FixedCostsAndMarginAd.fromJson(json['fixedCostsAndMargin']) : FixedCostsAndMarginAd(breadUnit: 0, packagingUnit: 0, operatingCost: 0, desiredProfitPercentage: 0)
  );

}

@HiveType(typeId: 1)
class PrincipalProteinModel {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double buyWeight;
  @HiveField(2)
  final double buyKgWeight;
  @HiveField(3)
  final double shrikagepercentage;
  @HiveField(4)
  final double weightPortionKg;

  PrincipalProteinModel({
    required this.name,
    required this.buyWeight,
    required this.buyKgWeight,
    required this.shrikagepercentage,
    required this.weightPortionKg,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'buyWeight': buyWeight,
    'buyKgWeight': buyKgWeight,
    'shrinkagepercentage': shrikagepercentage,
    'weightPortionKg': weightPortionKg,
  };

  //* JSON IMPORT
  factory PrincipalProteinModel.fromJson(Map<String, dynamic> json) => PrincipalProteinModel(
    name: json['name'],
    buyWeight: json['buyWeight'],
    buyKgWeight: json['buyKgWeight'],
    shrikagepercentage: json['shrinkagepercentage'],
    weightPortionKg: json['weightPortionKg'],
  );
}

@HiveType(typeId: 2)
class AdditionalIngredients {
  @HiveField(0)
  final List<Sections> sections;

  AdditionalIngredients({
    required this.sections,
  });

  Map<String, dynamic> toJson() => {
        "sections": sections.map((e) => e.toJson()).toList(),
      };

  factory AdditionalIngredients.fromJson(Map<String, dynamic> json) =>
      AdditionalIngredients(
        sections: (json["sections"] as List)
            .map((e) => Sections.fromJson(e))
            .toList(),
      );

}

@HiveType(typeId: 3)
class Sections {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<ItemsSections> items;

  Sections({required this.name, required this.items});

  Map<String, dynamic> toJson() => {
        "name": name,
        "items": items.map((e) => e.toJson()).toList(),
      };

  factory Sections.fromJson(Map<String, dynamic> json) => Sections(
        name: json["name"],
        items: (json["items"] as List)
            .map((e) => ItemsSections.fromJson(e))
            .toList(),
      );
}

@HiveType(typeId: 4)
class ItemsSections {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double kgCost;
  @HiveField(2)
  final double count;

  ItemsSections({
    required this.name,
    required this.kgCost,
    required this.count
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "kgCost": kgCost,
        "count": count,
      };

  factory ItemsSections.fromJson(Map<String, dynamic> json) => ItemsSections(
        name: json["name"],
        kgCost: json["kgCost"],
        count: json["count"],
      );
}

@HiveType(typeId: 5)
class FixedCostsAndMarginAd {
  
  @HiveField(0)
  final double breadUnit;
  
  @HiveField(1)
  final double packagingUnit;

  @HiveField(2)
  final double operatingCost;

  @HiveField(3)
  final double desiredProfitPercentage;

  FixedCostsAndMarginAd({
    required this.breadUnit,
    required this.packagingUnit,
    required this.operatingCost,
    required this.desiredProfitPercentage,
  });

  Map<String, dynamic> toJson() => {
    "breadUnit": breadUnit,
    "packagingUnit": packagingUnit,
    "operatingCost": operatingCost,
    "desiredProfitPercentage": desiredProfitPercentage,
  };

  factory FixedCostsAndMarginAd.fromJson(Map<String, dynamic> json) => FixedCostsAndMarginAd(
    breadUnit: (json["breadUnit"] ?? 0).toDouble(),
    packagingUnit: (json["packagingUnit"] ?? 0).toDouble(),
    operatingCost: (json["operatingCost"] ?? 0).toDouble(),
    desiredProfitPercentage: (json["desiredProfitPercentage"] ?? 0).toDouble(),
  );
}