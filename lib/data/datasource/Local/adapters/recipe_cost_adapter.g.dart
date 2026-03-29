// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_cost_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeCostModelAdapter extends TypeAdapter<RecipeCostModel> {
  @override
  final int typeId = 10;

  @override
  RecipeCostModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeCostModel(
      recipeName: fields[0] as String?,
      exchangeRate: fields[1] as double,
      mainIngredients: (fields[2] as List).cast<MainIngredientCost>(),
      additionalSections: (fields[3] as List).cast<AdditionalSectionCost>(),
      economicSummary: fields[4] as EconomicSummaryCost,
      businessMaintenance: fields[5] as BusinessMaintenanceCost,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeCostModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.recipeName)
      ..writeByte(1)
      ..write(obj.exchangeRate)
      ..writeByte(2)
      ..write(obj.mainIngredients)
      ..writeByte(3)
      ..write(obj.additionalSections)
      ..writeByte(4)
      ..write(obj.economicSummary)
      ..writeByte(5)
      ..write(obj.businessMaintenance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeCostModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MainIngredientCostAdapter extends TypeAdapter<MainIngredientCost> {
  @override
  final int typeId = 11;

  @override
  MainIngredientCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MainIngredientCost(
      name: fields[0] as String,
      wasteCalculations: fields[1] as WasteCalculationsCost,
      portion: fields[2] as PortionCost,
    );
  }

  @override
  void write(BinaryWriter writer, MainIngredientCost obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.wasteCalculations)
      ..writeByte(2)
      ..write(obj.portion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainIngredientCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WasteCalculationsCostAdapter extends TypeAdapter<WasteCalculationsCost> {
  @override
  final int typeId = 12;

  @override
  WasteCalculationsCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WasteCalculationsCost(
      initialWeightKg: fields[0] as double,
      wastePercentage: fields[1] as double,
      usableWeightKg: fields[2] as double,
      realPricePerKg: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WasteCalculationsCost obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.initialWeightKg)
      ..writeByte(1)
      ..write(obj.wastePercentage)
      ..writeByte(2)
      ..write(obj.usableWeightKg)
      ..writeByte(3)
      ..write(obj.realPricePerKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WasteCalculationsCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PortionCostAdapter extends TypeAdapter<PortionCost> {
  @override
  final int typeId = 13;

  @override
  PortionCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortionCost(
      weightUsedKg: fields[0] as double,
      cost: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PortionCost obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weightUsedKg)
      ..writeByte(1)
      ..write(obj.cost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortionCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdditionalSectionCostAdapter extends TypeAdapter<AdditionalSectionCost> {
  @override
  final int typeId = 14;

  @override
  AdditionalSectionCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdditionalSectionCost(
      sectionName: fields[0] as String?,
      items: (fields[1] as List).cast<AdditionalItemCost>(),
      sectionTotal: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AdditionalSectionCost obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.sectionName)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.sectionTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalSectionCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdditionalItemCostAdapter extends TypeAdapter<AdditionalItemCost> {
  @override
  final int typeId = 15;

  @override
  AdditionalItemCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdditionalItemCost(
      name: fields[0] as String,
      quantityKg: fields[1] as double,
      pricePerKg: fields[2] as String,
      subtotal: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AdditionalItemCost obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantityKg)
      ..writeByte(2)
      ..write(obj.pricePerKg)
      ..writeByte(3)
      ..write(obj.subtotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalItemCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EconomicSummaryCostAdapter extends TypeAdapter<EconomicSummaryCost> {
  @override
  final int typeId = 16;

  @override
  EconomicSummaryCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EconomicSummaryCost(
      totalIngredientsCost: fields[0] as String,
      expectedProfit: fields[1] as String,
      unitFixedExpenses: fields[2] as String,
      suggestedSalesPrice: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EconomicSummaryCost obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalIngredientsCost)
      ..writeByte(1)
      ..write(obj.expectedProfit)
      ..writeByte(2)
      ..write(obj.unitFixedExpenses)
      ..writeByte(3)
      ..write(obj.suggestedSalesPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EconomicSummaryCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BusinessMaintenanceCostAdapter
    extends TypeAdapter<BusinessMaintenanceCost> {
  @override
  final int typeId = 17;

  @override
  BusinessMaintenanceCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessMaintenanceCost(
      monthlyFixedExpenses: fields[0] as String,
      netProfitperUnit: fields[1] as String,
      unitsForBreakEven: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessMaintenanceCost obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.monthlyFixedExpenses)
      ..writeByte(1)
      ..write(obj.netProfitperUnit)
      ..writeByte(2)
      ..write(obj.unitsForBreakEven);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessMaintenanceCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
