import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  const AddressEntity({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.city,
    required this.district,
    required this.street,
    required this.building,
    required this.postalCode,
    required this.isDefault,
  });

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

  @override
  List<Object?> get props => [
        id,
        userId,
        label,
        fullName,
        phone,
        country,
        city,
        district,
        street,
        building,
        postalCode,
        isDefault,
      ];

  AddressEntity copyWith({
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
    return AddressEntity(
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
