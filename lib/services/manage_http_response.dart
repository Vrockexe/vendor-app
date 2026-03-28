import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void manageHttpResponse({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  try {
    final Map<String, dynamic> decoded = json.decode(response.body);
    switch (response.statusCode) {
      case 200:
      case 201:
        onSuccess();
        break;
      case 400:
        showSnackBar(context, decoded['msg']?.toString() ?? 'Bad request');
        break;
      case 500:
        showSnackBar(context, decoded['error']?.toString() ?? 'Server error');
        break;
      default:
        showSnackBar(context, 'Unexpected error: ${response.statusCode}');
    }
  } catch (e) {
    showSnackBar(context, 'Something went wrong');
  }
}


void showSnackBar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
}