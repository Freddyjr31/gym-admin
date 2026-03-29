// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_cost_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FixedCostAdapterAdapter extends TypeAdapter<FixedCostAdapter> {
  @override
  final int typeId = 20;

  @override
  FixedCostAdapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixedCostAdapter(
      fixedCostItems: (fields[0] as List).cast<FixedCostItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, FixedCostAdapter obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.fixedCostItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedCostAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FixedCostItemAdapter extends TypeAdapter<FixedCostItem> {
  @override
  final int typeId = 21;

  @override
  FixedCostItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FixedCostItem(
      nameCost: fields[0] as String,
      cost: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, FixedCostItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nameCost)
      ..writeByte(1)
      ..write(obj.cost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedCostItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
