import '../../domain/entities/address_entity.dart';

class AddressModel {
  final String id;
  final String userId;
  final String? label;
  final String fullName;
  final String phone;
  final String country;
  final String city;
  final String? district;
  final String street;
  final String? building;
  final String? postalCode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    this.label,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.city,
    this.district,
    required this.street,
    this.building,
    this.postalCode,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String?,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      district: json['district'] as String?,
      street: json['street'] as String,
      building: json['building'] as String?,
      postalCode: json['postal_code'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'full_name': fullName,
      'phone': phone,
      'country': country,
      'city': city,
      'district': district,
      'street': street,
      'building': building,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? fullName,
    String? phone,
    String? country,
    String? city,
    String? district,
    String? street,
    String? building,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      district: district ?? this.district,
      street: street ?? this.street,
      building: building ?? this.building,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
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
