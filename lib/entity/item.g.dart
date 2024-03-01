// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Item _$$_ItemFromJson(Map<String, dynamic> json) => _$_Item(
      id: json['id'] as String?,
      name: json['name'] as String,
      locationCategory: const LocationCategoryConverter()
          .fromJson(json['location_category'] as String?),
      category:
          const ItemCategoryConverter().fromJson(json['category'] as String?),
    );

Map<String, dynamic> _$$_ItemToJson(_$_Item instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location_category':
          const LocationCategoryConverter().toJson(instance.locationCategory),
      'category': const ItemCategoryConverter().toJson(instance.category),
    };
