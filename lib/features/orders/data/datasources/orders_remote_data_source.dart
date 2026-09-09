import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getUserOrders();
  Future<OrderModel> getOrderDetails(String orderId);
  Future<OrderModel> createOrder({
    required String paymentMethod,
    required double subtotal,
    required double shippingCost,
    required double tax,
    required double total,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    String? couponId,
    double discountAmount = 0.0,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this.supabaseClient);

  final SupabaseClient supabaseClient;

  @override
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      final response = await supabaseClient
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<OrderModel> getOrderDetails(String orderId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      final response = await supabaseClient
          .from('orders')
          .select('*, items:order_items(*)')
          .eq('id', orderId)
          .eq('user_id', userId)
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<OrderModel> createOrder({
    required String paymentMethod,
    required double subtotal,
    required double shippingCost,
    required double tax,
    required double total,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
    String? couponId,
    double discountAmount = 0.0,
  }) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      // Step 1: Create the order
      final orderData = <String, dynamic>{
        'user_id': userId,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'shipping_cost': shippingCost,
        'tax': tax,
        'total': total,
        'shipping_address': shippingAddress,
      };

      if (couponId != null) {
        orderData['coupon_id'] = couponId;
      }
      if (discountAmount > 0) {
        orderData['discount_amount'] = discountAmount;
      }

      final orderResponse =
          await supabaseClient.from('orders').insert(orderData).select().single();

      final orderId = orderResponse['id'] as String;

      // Step 2: Insert order items
      final orderItemsToInsert = items.map((item) {
        return {
          'order_id': orderId,
          'product_id': item['product_id'],
          'product_name_en': item['product_name_en'],
          'product_name_ar': item['product_name_ar'],
          'product_image': item['product_image'],
          'quantity': item['quantity'],
          'price_at_purchase': item['price_at_purchase'],
        };
      }).toList();

      await supabaseClient.from('order_items').insert(orderItemsToInsert);

      // Return the completed order model
      final completeOrderResponse = await supabaseClient
          .from('orders')
          .select('*, items:order_items(*)')
          .eq('id', orderId)
          .single();

      return OrderModel.fromJson(completeOrderResponse);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }
}
