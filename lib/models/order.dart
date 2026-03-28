// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Order {
  final String id;
  final String name;
  final String email;
  final String state;
  final String city;
  final String locality;
  final String productName;
  final int productPrice;
  final int quantity;
  final String category;
  final String image;
  final String buyerId;
  final String vendorId;
  final bool processing;
  final bool delivered;

  Order({required this.id, required this.name, required this.email, required this.state, required this.city, required this.locality, required this.productName, required this.productPrice, required this.quantity, required this.category, required this.image, required this.buyerId, required this.vendorId, required this.processing, required this.delivered});
  


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'state': state,
      'city': city,
      'locality': locality,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'category': category,
      'image': image,
      'buyerId': buyerId,
      'vendorId': vendorId,
      'processing': processing,
      'delivered': delivered,
    };
  }
    String toJson() => json.encode(toMap());


factory Order.fromJson(Map<String, dynamic> map) {
  return Order(
    id: map['_id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    state: map['state']?.toString() ?? '',
    city: map['city']?.toString() ?? '',
    locality: map['locality']?.toString() ?? '',
    productName: map['productName']?.toString() ?? '',
    productPrice: (map['productPrice'] ?? 0).toInt(),
    quantity: (map['quantity'] ?? 0).toInt(),
    category: map['category']?.toString() ?? '',
    image: map['image']?.toString() ?? '',
    buyerId: map['buyerId']?.toString() ?? '',
    vendorId: map['vendorId']?.toString() ?? '',
    processing: map['processing'] ?? false,
    delivered: map['delivered'] ?? false,
  );
}


  
}