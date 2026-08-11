import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';

class AdminOrderDetailScreen extends ConsumerStatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.order});
  final Map<String, dynamic> order;
  @override
  ConsumerState<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends ConsumerState<AdminOrderDetailScreen> {
  late String _status;
  bool _isUpdating = false;
  static const _statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _status = widget.order['status']?.toString() ?? 'pending';
  }

  String _localizeStatus(String s, bool isAr) {
    if (!isAr) return s.toUpperCase();
    switch (s) {
      case 'all': return 'الكل';
      case 'pending': return 'قيد الانتظار';
      case 'processing': return 'جاري التجهيز';
      case 'shipped': return 'تم الشحن';
      case 'delivered': return 'تم التوصيل';
      case 'cancelled': return 'ملغي';
      default: return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final items = widget.order['order_items'] as List? ?? [];
    final address = widget.order['shipping_address'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text('${isAr ? 'طلب' : 'Order'} #${widget.order['order_number'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => GoRouter.of(context).pop()),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Status Update
        _buildCard(isDark, isAr ? 'تحديث حالة الطلب' : 'Update Order Status', [
          Row(children: _statuses.map((s) {
            final selected = _status == s;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _status = s),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _statusColor(s) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selected ? _statusColor(s) : Colors.grey.shade300),
                ),
                child: Column(children: [
                  Icon(_statusIcon(s), color: selected ? Colors.white : Colors.grey, size: 18),
                  Text(_localizeStatus(s, isAr), style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 9, fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
                ]),
              ),
            ));
          }).toList()),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : _updateStatus,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: _isUpdating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_rounded, color: Colors.white),
            label: Text(_isUpdating ? (isAr ? 'جاري التحديث...' : 'Updating...') : (isAr ? 'تأكيد تحديث الحالة' : 'Confirm Status Update'), style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
          )),
        ]),
        const SizedBox(height: 16),
        // Order Summary
        _buildCard(isDark, isAr ? 'ملخص الطلب' : 'Order Summary', [
          _buildInfoRow(isAr ? 'رقم الطلب' : 'Order Number', widget.order['order_number']?.toString() ?? 'N/A'),
          _buildInfoRow(isAr ? 'طريقة الدفع' : 'Payment Method', widget.order['payment_method']?.toString() ?? 'N/A'),
          _buildInfoRow(isAr ? 'المجموع الفرعي' : 'Subtotal', '${(widget.order['subtotal'] as num?)?.toStringAsFixed(2) ?? '0'} ${isAr ? 'ر.س' : 'SAR'}'),
          _buildInfoRow(isAr ? 'الشحن' : 'Shipping', '${(widget.order['shipping_cost'] as num?)?.toStringAsFixed(2) ?? '0'} ${isAr ? 'ر.س' : 'SAR'}'),
          _buildInfoRow(isAr ? 'الضريبة' : 'Tax', '${(widget.order['tax'] as num?)?.toStringAsFixed(2) ?? '0'} ${isAr ? 'ر.س' : 'SAR'}'),
          const Divider(),
          _buildInfoRow(isAr ? 'الإجمالي' : 'Total', '${(widget.order['total'] as num?)?.toStringAsFixed(2) ?? '0'} ${isAr ? 'ر.س' : 'SAR'}', bold: true, color: AppColors.primary),
        ]),
        const SizedBox(height: 16),
        // Items
        _buildCard(isDark, '${isAr ? 'عناصر الطلب' : 'Order Items'} (${items.length})', items.map<Widget>((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8),
              child: item['product_image'] != null ? Image.network(item['product_image']!.toString(), width: 56, height: 56, fit: BoxFit.cover)
                  : Container(width: 56, height: 56, color: AppColors.primaryLight, child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item[isAr ? 'product_name_ar' : 'product_name_en']?.toString() ?? (isAr ? 'منتج' : 'Product'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${isAr ? 'الكمية' : 'Qty'}: ${item['quantity'] ?? 1}', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight)),
            ])),
            Text('${(item['price_at_purchase'] as num?)?.toStringAsFixed(2) ?? '0'} ${isAr ? 'ر.س' : 'SAR'}', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
        )).toList()),
        const SizedBox(height: 16),
        // Shipping Address
        if (address.isNotEmpty)
          _buildCard(isDark, isAr ? 'عنوان الشحن' : 'Shipping Address', [
            _buildInfoRow(isAr ? 'الاسم' : 'Name', address['full_name']?.toString() ?? ''),
            _buildInfoRow(isAr ? 'رقم الهاتف' : 'Phone', address['phone']?.toString() ?? ''),
            _buildInfoRow(isAr ? 'المدينة' : 'City', address['city']?.toString() ?? ''),
            _buildInfoRow(isAr ? 'الشارع' : 'Street', address['street']?.toString() ?? ''),
            if (address['district'] != null) _buildInfoRow(isAr ? 'الحي' : 'District', address['district']!.toString()),
            if (address['building'] != null) _buildInfoRow(isAr ? 'المبنى' : 'Building', address['building']!.toString()),
          ]),
        if (address.isNotEmpty) const SizedBox(height: 16),
        if (widget.order['notes'] != null && widget.order['notes'].toString().isNotEmpty)
          _buildCard(isDark, isAr ? 'ملاحظات' : 'Notes', [Text(widget.order['notes'].toString(), style: const TextStyle(fontFamily: 'Outfit'))]),
      ]),
    );
  }

  Widget _buildCard(bool isDark, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primary)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text('$label: ', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
        Expanded(child: Text(value, style: TextStyle(fontFamily: 'Outfit', fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color))),
      ]),
    );
  }

  Future<void> _updateStatus() async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(adminDataSourceProvider).updateOrderStatus(widget.order['id'] as String, _status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order status updated!', style: TextStyle(fontFamily: 'Outfit')), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Color _statusColor(String s) => switch (s) { 'pending' => AppColors.warning, 'processing' => AppColors.info, 'shipped' => AppColors.primary, 'delivered' => AppColors.success, 'cancelled' => AppColors.error, _ => Colors.grey };
  IconData _statusIcon(String s) => switch (s) { 'pending' => Icons.pending_actions_rounded, 'processing' => Icons.autorenew_rounded, 'shipped' => Icons.local_shipping_rounded, 'delivered' => Icons.check_circle_rounded, 'cancelled' => Icons.cancel_rounded, _ => Icons.help };
}

