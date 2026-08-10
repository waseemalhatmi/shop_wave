import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/address_entity.dart';
import '../providers/addresses_providers.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({
    this.addressToEdit,
    super.key,
  });

  final AddressEntity? addressToEdit;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _labelController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  late final TextEditingController _streetController;
  late final TextEditingController _buildingController;
  late final TextEditingController _postalCodeController;
  
  bool _isDefault = false;

  bool get _isEditing => widget.addressToEdit != null;

  @override
  void initState() {
    super.initState();
    final addr = widget.addressToEdit;
    _labelController = TextEditingController(text: addr?.label);
    _fullNameController = TextEditingController(text: addr?.fullName);
    _phoneController = TextEditingController(text: addr?.phone);
    _cityController = TextEditingController(text: addr?.city);
    _districtController = TextEditingController(text: addr?.district);
    _streetController = TextEditingController(text: addr?.street);
    _buildingController = TextEditingController(text: addr?.building);
    _postalCodeController = TextEditingController(text: addr?.postalCode);
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userAddressesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isLoading = state is AsyncLoading;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _labelController,
                  label: 'Address Label (e.g. Home, Work)',
                  hint: 'Home',
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'John Doe',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+966 50 123 4567',
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'Riyadh',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _districtController,
                  label: 'District',
                  hint: 'Al Malaz',
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  controller: _streetController,
                  label: 'Street Name',
                  hint: 'King Abdulaziz Road',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _buildingController,
                        label: 'Building No / Name',
                        hint: 'Building 12',
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'Postal Code',
                        hint: '12345',
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile(
                  title: const Text(
                    'Set as default shipping address',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  value: _isDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: isLoading ? null : (val) => setState(() => _isDefault = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : Text(
                            _isEditing ? 'Save Changes' : 'Save Address',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          style: const TextStyle(fontFamily: 'Outfit'),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final address = AddressEntity(
        id: widget.addressToEdit?.id ?? '',
        userId: widget.addressToEdit?.userId ?? '',
        label: _labelController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: 'SA',
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        street: _streetController.text.trim(),
        building: _buildingController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        isDefault: _isDefault,
      );

      if (_isEditing) {
        await ref.read(userAddressesProvider.notifier).updateAddress(address);
      } else {
        await ref.read(userAddressesProvider.notifier).addAddress(address);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
