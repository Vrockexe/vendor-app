import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/order.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController {
  //Method to GET Orders by Vendor ID

  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('auth_token');
      //Send an HTTP GET request to get the orders by the buyerID
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/vendors/$vendorId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          "x-auth-token": token!,
          
        },
        
      );
      //Check if the response status code is 200(OK).
      if (response.statusCode == 200) {
  List<dynamic> data = jsonDecode(response.body);
  return data.map((order) => Order.fromJson(order)).toList();
} else {
  throw Exception("Failed to load orders: ${response.statusCode}");
}
    } catch (e) {
  print('Order fetch error: $e');  // Add this
  throw Exception('error Loading Orders');
}
  }

  //delete order by ID
  Future<void> deleteOrder({required String id, required context}) async {
    try {
      //send an HTTP Delete request to delete the order by _id
      http.Response response = await http.delete(
        Uri.parse("$uri/api/orders/$id"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      //handle the HTTP Response
      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Order Deleted successfully');
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateDeliveryStatus(
      {required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/delivered'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          "delivered": true,
          "processing": false,
        }),
      );

      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Order Updated');
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> cancelOrder({required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/processing'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          "processing": false,
          "delivered": false,
        }),
      );

      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Order Canceled');
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
