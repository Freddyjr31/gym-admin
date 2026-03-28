

class RecipeRequestModel {
  String recipeName;
  List<MainIngredient> mainIngredients;
  List<AdditionalSectionRequest> additionalSectionsRequest;
  FixedCostsAndMargin fixedCostsAndMargin;

  RecipeRequestModel({
    required this.recipeName,
    required this.mainIngredients,
    required this.additionalSectionsRequest,
    required this.fixedCostsAndMargin,
  });

  Map<String, dynamic> toJson() => {
    "mainIngredients": mainIngredients.map((x) => x.toJson()).toList(),
    "additionalSectionsRequest": additionalSectionsRequest.map((x) => x.toJson()).toList(),
    "fixedCostsAndMargin": fixedCostsAndMargin.toJson(),
  };

  factory RecipeRequestModel.fromJson(Map<String, dynamic> json) => RecipeRequestModel(
    recipeName: json["recipeName"],
    mainIngredients: List<MainIngredient>.from(json["mainIngredients"].map((x) => MainIngredient.fromJson(x))),
    additionalSectionsRequest: List<AdditionalSectionRequest>.from(json["additionalSectionsRequest"].map((x) => AdditionalSectionRequest.fromJson(x))),
    fixedCostsAndMargin: FixedCostsAndMargin.fromJson(json["fixedCostsAndMargin"]),
  );
}

class MainIngredient {
  String name;
  double purchaseWeightKg;
  double purchasePricePerKg;
  double wastePercentage;
  double weightPerPortionKg;

  MainIngredient({
    required this.name,
    required this.purchaseWeightKg,
    required this.purchasePricePerKg,
    required this.wastePercentage,
    required this.weightPerPortionKg,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "purchaseWeightKg": purchaseWeightKg,
    "purchasePricePerKg": purchasePricePerKg,
    "wastePercentage": wastePercentage,
    "weightPerPortionKg": weightPerPortionKg,
  };

  factory MainIngredient.fromJson(Map<String, dynamic> json) => MainIngredient(
    name: json["name"] ?? "",
    purchaseWeightKg: (json["purchaseWeightKg"] ?? 0).toDouble(),
    purchasePricePerKg: (json["purchasePricePerKg"] ?? 0).toDouble(),
    wastePercentage: (json["wastePercentage"] ?? 0).toDouble(),
    weightPerPortionKg: (json["weightPerPortionKg"] ?? 0).toDouble(),
  );
}

class AdditionalSectionRequest {
  String name;
  List<Item> items;

  AdditionalSectionRequest({required this.items, required this.name});

  Map<String, dynamic> toJson() => {
    "items": items.map((x) => x.toJson()).toList(),
  };

  factory AdditionalSectionRequest.fromJson(Map<String, dynamic> json) => AdditionalSectionRequest(
    name: json["name"] ?? "",
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );
}

class Item {
  String name;
  double pricePerKg;
  double quantityKg;

  Item({
    required this.name,
    required this.pricePerKg,
    required this.quantityKg,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "pricePerKg": pricePerKg,
    "quantityKg": quantityKg,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    name: json["name"] ?? "",
    pricePerKg: (json["pricePerKg"] ?? 0).toDouble(),
    quantityKg: (json["quantityKg"] ?? 0).toDouble(),
  );
}

class FixedCostsAndMargin {
  double breadUnit;
  double packagingUnit;
  double operatingCost;
  double desiredProfitPercentage;

  FixedCostsAndMargin({
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

  factory FixedCostsAndMargin.fromJson(Map<String, dynamic> json) => FixedCostsAndMargin(
    breadUnit: (json["breadUnit"] ?? 0).toDouble(),
    packagingUnit: (json["packagingUnit"] ?? 0).toDouble(),
    operatingCost: (json["operatingCost"] ?? 0).toDouble(),
    desiredProfitPercentage: (json["desiredProfitPercentage"] ?? 0).toDouble(),
  );
}