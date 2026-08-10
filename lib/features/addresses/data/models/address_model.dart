// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/address_entity.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String? label,
    @JsonKey(name: 'full_name') required String fullName,
    required String phone,
    required String country,
    required String city,
    required String? district,
    required String street,
    required String? building,
    @JsonKey(name: 'postal_code') required String? postalCode,
    @JsonKey(name: 'is_default') required bool isDefault,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
}

extension AddressModelX on AddressModel {
  AddressEntity toDomain() => AddressEntity(
        id: id,
        userId: userId,
        label: label,
        fullName: fullName,
        phone: phone,
        country: country,
        city: city,
        district: district,
        street: street,
        building: building,
        postalCode: postalCode,
        isDefault: isDefault,
      );

  static AddressModel fromDomain(AddressEntity a) => AddressModel(
        id: a.id,
        userId: a.userId,
        label: a.label,
        fullName: a.fullName,
        phone: a.phone,
        country: a.country,
        city: a.city,
        district: a.district,
        street: a.street,
        building: a.building,
        postalCode: a.postalCode,
        isDefault: a.isDefault,
      );
}
