import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/models/vendor.dart';

//StateNotifier: StateNotifier is a class provided by Riverpod package  that helps in
//managing  the state , it is also designed to notify listeners abut the state changes
class VendorProvider extends StateNotifier<Vendor?> {
  VendorProvider()
      : super(Vendor(
            id: '',
            name: '',
            email: '',
            state: '',
            city: '',
            locality: '',
            role: '',
            password: ''));

  //Getter Method to extract  value from an object
  Vendor? get vendor => state;
  //Method to set vendor user state from json
  //purpose: updates the user state base on json String  respresentaion  of the user vendor object to Dart object
  //so that we can use it within the application

  void setVendor(String vendorJson) {
    state = Vendor.fromJson(vendorJson);
  }

  //method to clear the vendor user state
  void signOut() {
    state = null;
  }
}

///make the data accisible  within the application
final vendorProvider = StateNotifierProvider<VendorProvider, Vendor?>((ref) {
  return VendorProvider();
});
