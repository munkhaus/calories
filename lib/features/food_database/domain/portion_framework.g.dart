// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portion_framework.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmartPortionSizeImpl _$$SmartPortionSizeImplFromJson(
  Map<String, dynamic> json,
) => _$SmartPortionSizeImpl(
  name: json['name'] as String,
  grams: (json['grams'] as num).toDouble(),
  unit: $enumDecode(_$PortionUnitEnumMap, json['unit']),
  size: $enumDecode(_$PortionSizeEnumMap, json['size']),
  isDefault: json['isDefault'] as bool? ?? false,
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$$SmartPortionSizeImplToJson(
  _$SmartPortionSizeImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'grams': instance.grams,
  'unit': _$PortionUnitEnumMap[instance.unit]!,
  'size': _$PortionSizeEnumMap[instance.size]!,
  'isDefault': instance.isDefault,
  'description': instance.description,
};

const _$PortionUnitEnumMap = {
  PortionUnit.gram: 'gram',
  PortionUnit.piece: 'piece',
  PortionUnit.slice: 'slice',
  PortionUnit.cup: 'cup',
  PortionUnit.spoon: 'spoon',
  PortionUnit.glass: 'glass',
  PortionUnit.bottle: 'bottle',
  PortionUnit.can: 'can',
  PortionUnit.portion: 'portion',
  PortionUnit.handful: 'handful',
  PortionUnit.milliliter: 'milliliter',
  PortionUnit.deciliter: 'deciliter',
  PortionUnit.liter: 'liter',
};

const _$PortionSizeEnumMap = {
  PortionSize.extraSmall: 'extraSmall',
  PortionSize.small: 'small',
  PortionSize.medium: 'medium',
  PortionSize.large: 'large',
  PortionSize.extraLarge: 'extraLarge',
};
