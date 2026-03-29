// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeModelAdapter extends TypeAdapter<RecipeModel> {
  @override
  final int typeId = 0;

  @override
  RecipeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeModel(
      name: fields[0] as String,
      principalProtein: (fields[1] as List).cast<PrincipalProteinModel>(),
      additionalsingredients: fields[2] as AdditionalIngredients?,
      recipeCostModel: fields[3] as RecipeCostModel?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.principalProtein)
      ..writeByte(2)
      ..write(obj.additionalsingredients)
      ..writeByte(3)
      ..write(obj.recipeCostModel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrincipalProteinModelAdapter extends TypeAdapter<PrincipalProteinModel> {
  @override
  final int typeId = 1;

  @override
  PrincipalProteinModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrincipalProteinModel(
      name: fields[0] as String,
      buyWeight: fields[1] as double,
      buyKgWeight: fields[2] as double,
      shrikagepercentage: fields[3] as double,
      weightPortionKg: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PrincipalProteinModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.buyWeight)
      ..writeByte(2)
      ..write(obj.buyKgWeight)
      ..writeByte(3)
      ..write(obj.shrikagepercentage)
      ..writeByte(4)
      ..write(obj.weightPortionKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrincipalProteinModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdditionalIngredientsAdapter extends TypeAdapter<AdditionalIngredients> {
  @override
  final int typeId = 2;

  @override
  AdditionalIngredients read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdditionalIngredients(
      sections: (fields[0] as List).cast<Sections>(),
    );
  }

  @override
  void write(BinaryWriter writer, AdditionalIngredients obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.sections);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalIngredientsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SectionsAdapter extends TypeAdapter<Sections> {
  @override
  final int typeId = 3;

  @override
  Sections read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sections(
      name: fields[0] as String,
      items: (fields[1] as List).cast<ItemsSections>(),
    );
  }

  @override
  void write(BinaryWriter writer, Sections obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemsSectionsAdapter extends TypeAdapter<ItemsSections> {
  @override
  final int typeId = 4;

  @override
  ItemsSections read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemsSections(
      name: fields[0] as String,
      kgCost: fields[1] as double,
      count: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ItemsSections obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.kgCost)
      ..writeByte(2)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemsSectionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
