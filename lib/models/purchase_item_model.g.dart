// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseItemAdapter extends TypeAdapter<PurchaseItem> {
  @override
  final int typeId = 4;

  @override
  PurchaseItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseItem(
      supplierName: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      costPrice: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.supplierName)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.costPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
