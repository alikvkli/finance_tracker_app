import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String name;
  final String nameTr;
  final String nameEn;
  final String type;
  final String icon;
  final String color;
  final int? parentId;
  final int sortOrder;
  final bool isActive;
  final bool isDefault;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.nameEn,
    required this.type,
    required this.icon,
    required this.color,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.isDefault,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameTr: json['name_tr'] as String,
      nameEn: json['name_en'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      parentId: json['parent_id'] as int?,
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool,
      isDefault: json['is_default'] as bool,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_tr': nameTr,
      'name_en': nameEn,
      'type': type,
      'icon': icon,
      'color': color,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive,
      'is_default': isDefault,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameTr,
    nameEn,
    type,
    icon,
    color,
    parentId,
    sortOrder,
    isActive,
    isDefault,
    description,
    createdAt,
    updatedAt,
  ];
}
