import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/models/order.dart';

class OrderProvider extends StateNotifier<List<Order>> {
  OrderProvider() : super([]);

  //set the list of Orders
  void setOrders(List<Order> orders) {
    state = orders;
  }

  void updateOrderStatus(String orderId, {bool? processing, bool? delivered}) {
    //update the state of the provider with a new list of orders
    state = [
      //iterate through the existing orders
      for (final order in state)
        //check if the current order's Id matches the ID we want to update
        if (order.id == orderId)
          //create new Order object with the updated status
          Order(
            id: order.id, name: order.name,
            email: order.email,
            state: order.state,
            city: order.city,
            locality: order.locality,
            productName: order.productName,
            productPrice: order.productPrice,
            quantity: order.quantity,
            category: order.category,
            image: order.image,
            buyerId: order.buyerId,
            vendorId: order.vendorId,
            //Use the new processing status  if provided , otherwise  keep the current state
            processing: processing ?? order.processing,
            //Use the new processing status  if provided , otherwise  keep the current state
            delivered: delivered ?? order.delivered,
          )
          //if the current order's ID does not match , keep the order unchange
          else
          order,
    ];
  }
}

final orderProvider = StateNotifierProvider<OrderProvider, List<Order>>(
  (ref) {
    return OrderProvider();
  },
);
