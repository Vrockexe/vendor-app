// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Subcategory {
  final String id;
  final String categoryId;
  final String categoryName;
  final String image;
  final String subcategoryName;

  Subcategory({required this.id, required this.categoryId, required this.categoryName, required this.image, required this.subcategoryName});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'image': image,
      'subcategoryName': subcategoryName,
    };
  }

   String toJson() => json.encode(toMap());

  factory Subcategory.fromJson(Map<String, dynamic> map) {
    return Subcategory(
      id: map['_id'] as String,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      image: map['image'] as String,
      subcategoryName: map['subcategoryName'] as String,
    );
  }

 

}