// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order_item_entity.dart';

part 'order_item_model.freezed.dart';
part 'order_item_model.g.dart';

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'product_name_en') required String productNameEn,
    @JsonKey(name: 'product_name_ar') required String productNameAr,
    @JsonKey(name: 'product_image') required String productImage,
    required int quantity,
    @JsonKey(name: 'price_at_purchase') required double priceAtPurchase,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}

extension OrderItemModelX on OrderItemModel {
  OrderItemEntity toDomain() => OrderItemEntity(
        id: id,
        orderId: orderId,
        productId: productId,
        productNameEn: productNameEn,
        productNameAr: productNameAr,
        productImage: productImage,
        quantity: quantity,
        priceAtPurchase: priceAtPurchase,
        createdAt: createdAt,
      );
}
