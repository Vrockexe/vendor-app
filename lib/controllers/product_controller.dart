import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/product.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductController {
  Future<void> uploadProduct({
    required String productName,
    required int productPrice,
    required int quantity,
    required String description,
    required String category,
    required String vendorId,
    required String name,
    required String subCategory,
    required List<File>? pickedImages,
    required context,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('auth_token');

    if (pickedImages != null && pickedImages.isNotEmpty) {
      final cloudinary = CloudinaryPublic("dxnhiwolx", "usujk7on");
      List<String> images = [];

      for (var i = 0; i < pickedImages.length; i++) {
        CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedImages[i].path, folder: productName),
        );
        images.add(cloudinaryResponse.secureUrl);
      }

      if (category.isNotEmpty && subCategory.isNotEmpty) {
        final Product product = Product(
          id: '',
          productName: productName,
          productPrice: productPrice,
          quantity: quantity,
          description: description,
          category: category,
          vendorId: vendorId,
          name: name,
          subCategory: subCategory,
          images: images,
        );

        http.Response response = await http.post(
          Uri.parse("$uri/post/add-product"),
          body: jsonEncode(product.toMap()),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8",
            if (token != null) "x-auth-token": token,
          },
        );

        manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Product Uploaded');
          },
        );
      } else {
        showSnackBar(context, 'Select Category and Subcategory');
      }
    } else {
      showSnackBar(context, 'Select at least one image');
    }
  }

  Future<List<Product>> getProductsByCategoryAndSubcategory({
    required String category,
    required String subCategory,
    required String vendorId,
  }) async {
       try {
    final url = Uri.parse("$uri/api/products/vendor/$vendorId");
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Product.fromMap(item))
          .where((product) =>
              product.category == category &&
              product.subCategory == subCategory)
          .toList();
    } else {
      throw Exception("Failed to load products");
    }
  } catch (e) {
    throw Exception("Error fetching products: $e");
  }
}

Future<void> updateProduct({
  required Product product,
  required BuildContext context,
}) async {
  try {
    final url = Uri.parse("$uri/api/products/${product.id}");
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product.toMap()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // 🔍 DEBUG PRINT

    manageHttpResponse(
      response: response,
      context: context,
      onSuccess: () {
        showSnackBar(context, 'Product Updated');
      },
    );
  } catch (e) {
    showSnackBar(context, 'Failed to update product: $e');
  }
}

}