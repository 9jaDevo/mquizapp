import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.isPremium,
    required this.coins,
    required this.rowOrder,
    this.type,
    this.image,
    this.maxLevel,
    this.subcategoriesCount,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: parseIntOr(j['id'], 0),
        name: parseStringOr(j['categoryName'] ?? j['name'], 'Category'),
        slug: parseStringOr(j['slug'], ''),
        isPremium: parseBool(j['isPremium']),
        coins: parseIntOr(j['coins'], 0),
        rowOrder: parseIntOr(j['rowOrder'], 0),
        type: parseString(j['type']),
        image: parseString(j['image']),
        maxLevel: parseInt(j['maxLevel']),
        subcategoriesCount: parseInt(j['subcategoriesCount']),
      );

  final int id;
  final String name;
  final String slug;
  final bool isPremium;
  final int coins;
  final int rowOrder;
  final String? type;
  final String? image;
  final int? maxLevel;
  final int? subcategoriesCount;

  @override
  List<Object?> get props => [id, name, slug, isPremium, coins, rowOrder];
}

class Subcategory extends Equatable {
  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.maxLevel,
    this.image,
    this.slug,
  });

  factory Subcategory.fromJson(Map<String, dynamic> j) => Subcategory(
        id: parseIntOr(j['id'], 0),
        categoryId: parseIntOr(j['categoryId'], 0),
        name: parseStringOr(j['subcategoryName'] ?? j['name'], 'Topic'),
        maxLevel: parseIntOr(j['maxLevel'], 1),
        image: parseString(j['image']),
        slug: parseString(j['slug']),
      );

  final int id;
  final int categoryId;
  final String name;
  final int maxLevel;
  final String? image;
  final String? slug;

  @override
  List<Object?> get props => [id, categoryId, name, maxLevel];
}
