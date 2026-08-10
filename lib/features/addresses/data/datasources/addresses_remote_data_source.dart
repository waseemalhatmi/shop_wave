import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/address_model.dart';

abstract class AddressesRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}

class AddressesRemoteDataSourceImpl implements AddressesRemoteDataSource {
  const AddressesRemoteDataSourceImpl(this.supabaseClient);

  final SupabaseClient supabaseClient;

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      final response = await supabaseClient
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      // If this is set as default, reset other addresses
      if (address.isDefault) {
        await supabaseClient
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final addressData = {
        'user_id': userId,
        'label': address.label,
        'full_name': address.fullName,
        'phone': address.phone,
        'country': address.country,
        'city': address.city,
        'district': address.district,
        'street': address.street,
        'building': address.building,
        'postal_code': address.postalCode,
        'is_default': address.isDefault,
      };

      final response = await supabaseClient
          .from('addresses')
          .insert(addressData)
          .select()
          .single();

      return AddressModel.fromJson(response);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      // If updated address is set as default, reset others
      if (address.isDefault) {
        await supabaseClient
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final response = await supabaseClient
          .from('addresses')
          .update({
            'label': address.label,
            'full_name': address.fullName,
            'phone': address.phone,
            'country': address.country,
            'city': address.city,
            'district': address.district,
            'street': address.street,
            'building': address.building,
            'postal_code': address.postalCode,
            'is_default': address.isDefault,
          })
          .eq('id', address.id)
          .select()
          .single();

      return AddressModel.fromJson(response);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await supabaseClient.from('addresses').delete().eq('id', id);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerAppException('User not authenticated');
      }

      // 1. Reset all addresses to not default
      await supabaseClient
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId);

      // 2. Set chosen address to default
      await supabaseClient
          .from('addresses')
          .update({'is_default': true})
          .eq('id', id);
    } catch (e) {
      throw ServerAppException(e.toString());
    }
  }
}
