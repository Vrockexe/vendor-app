import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/vendor.dart';
import 'package:http/http.dart' as http;
import 'package:mac_vendor_store/provider/vendor_provider.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:mac_vendor_store/views/screens/authentication/login_screen.dart';
import 'package:mac_vendor_store/views/screens/main_vendor_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signUpVendor({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      Vendor vendor = Vendor(
        id: '',
        name: name,
        email: email,
        state: '',
        city: '',
        locality: '',
        role: '',
        password: password,
      );

      final response = await http.post(
        Uri.parse("$uri/api/vendor/signup"),
        body: vendor.toJson(),
        headers: {
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Vendor Account Created');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> signInVendor({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$uri/api/vendor/signin'),
        body: jsonEncode({"email": email, "password": password}),
        headers: {
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          final SharedPreferences prefs =
              await SharedPreferences.getInstance();

          final String token = jsonDecode(response.body)['token'];
          final vendorData = jsonEncode(jsonDecode(response.body)['vendor']);

          await prefs.setString('auth_token', token);
          await prefs.setString('vendor', vendorData);

          providerContainer
              .read(vendorProvider.notifier)
              .setVendor(vendorData);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainVendorScreen()),
            (route) => false,
          );

          showSnackBar(context, 'Logged in successfully');
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  Future<void> signOutUser({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$uri/api/signout'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        await prefs.remove('vendor');
        ref.read(vendorProvider.notifier).signOut();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );

        showSnackBar(context, 'Signed out successfully');
      } else {
        showSnackBar(context, 'Failed to sign out: ${response.body}');
      }
    } catch (e) {
      showSnackBar(context, 'Error signing out: $e');
    }
  }

  Future<void> deleteAccount({
    required BuildContext context,
    required String id,
    required WidgetRef ref,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse('$uri/api/vendors/$id'),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token ?? "",
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          await prefs.remove('auth_token');
          await prefs.remove('vendor');
          ref.read(vendorProvider.notifier).signOut();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );

          showSnackBar(context, 'Account deleted successfully');
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error deleting account: $e');
    }
  }
}
