
import 'package:cook_ledger/data/models/additional_ingredients_model.dart';

class RecipeModel {
  final String name;
  final PrincipalProteinModel principalProtein;
  final AdditionalIngredients? additionalsingredients;

  RecipeModel({
    required this.name,
    required this.principalProtein,
    this.additionalsingredients
  });
}


class PrincipalProteinModel {

  final String name;
  final double buyWeight;
  final double buyKgWeight;
  final double shrikagepercentage;
  final double weightPortionKg;

  PrincipalProteinModel({
    required this.name,
    required this.buyWeight,
    required this.buyKgWeight,
    required this.shrikagepercentage,
    required this.weightPortionKg
  });
}