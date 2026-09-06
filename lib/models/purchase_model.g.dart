// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplierPurchaseAdapter extends TypeAdapter<SupplierPurchase> {
  @override
  final int typeId = 6;

  @override
  SupplierPurchase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplierPurchase(
      supplierName: fields[0] as String,
      phoneNumber: fields[1] as String,
      itemName: fields[2] as String,
      quantity: fields[3] as double,
      purchasePrice: fields[4] as double,
      paidAmount: fields[5] as double,
      note: fields[6] as String,
      date: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SupplierPurchase obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.supplierName)
      ..writeByte(1)
      ..write(obj.phoneNumber)
      ..writeByte(2)
      ..write(obj.itemName)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.purchasePrice)
      ..writeByte(5)
      ..write(obj.paidAmount)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierPurchaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
