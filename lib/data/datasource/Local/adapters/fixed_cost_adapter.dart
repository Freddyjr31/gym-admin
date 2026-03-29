
import 'package:hive/hive.dart';

part 'fixed_cost_adapter.g.dart';

@HiveType(typeId: 20)
class FixedCostAdapter extends HiveObject{

  @HiveField(0)
  final List<FixedCostItem> fixedCostItems;
  
  FixedCostAdapter({
    required this.fixedCostItems,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'fixedCostItems': fixedCostItems,
  };

  //* JSON IMPORT
  factory FixedCostAdapter.fromJson(Map<String, dynamic> json) => FixedCostAdapter(
    fixedCostItems: List<FixedCostItem>.from(json['fixedCostItems'].map((x) => FixedCostItem.fromJson(x))),
  );
}


@HiveType(typeId: 21)
class FixedCostItem {

  @HiveField(0)
  final String nameCost;

  @HiveField(1)
  final double cost;

  FixedCostItem({
    required this.nameCost,
    required this.cost,
  });

  //* TO JSON
  Map<String, dynamic> toJson() => {
    'nameCost': nameCost,
    'cost': cost,
  };

  //* JSON IMPORT
  factory FixedCostItem.fromJson(Map<String, dynamic> json) => FixedCostItem(
    nameCost: json['nameCost'],
    cost: json['cost'],
  );
}
