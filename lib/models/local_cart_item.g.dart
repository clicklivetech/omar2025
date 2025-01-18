// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalCartItemAdapter extends TypeAdapter<LocalCartItem> {
  @override
  final int typeId = 1;

  @override
  LocalCartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalCartItem(
      product: fields[0] as Product,
      quantity: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LocalCartItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
