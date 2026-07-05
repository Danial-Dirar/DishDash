import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/offer_model.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../services/offer_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_helper.dart';

class PostOfferScreen extends StatefulWidget {
  /// When non-null the screen edits an existing offer instead of creating one.
  final Offer? offer;
  const PostOfferScreen({super.key, this.offer});

  @override
  State<PostOfferScreen> createState() => _PostOfferScreenState();
}

class _PostOfferScreenState extends State<PostOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _originalCtrl = TextEditingController();
  final _discountedCtrl = TextEditingController();
  final _promoCtrl = TextEditingController();

  String? _imageBase64;
  String _category = 'Combo';
  DateTime? _scheduledAt; // null = publish now
  DateTime? _expiresAt;
  bool _saving = false;
  String _companyName = '';

  static const _categories = [
    'Combo',
    'Discount',
    'Buy 1 Get 1',
    'Happy Hour',
    'Dessert',
    'Beverage',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Other',
  ];

  bool get _isEditing => widget.offer != null;

  @override
  void initState() {
    super.initState();
    final o = widget.offer;
    if (o != null) {
      _titleCtrl.text = o.title;
      _descCtrl.text = o.description;
      _originalCtrl.text = o.originalPrice?.toStringAsFixed(0) ?? '';
      _discountedCtrl.text = o.discountedPrice?.toStringAsFixed(0) ?? '';
      _promoCtrl.text = o.promoCode ?? '';
      _imageBase64 = o.imageBase64;
      _category = _categories.contains(o.category) ? o.category! : 'Other';
      _scheduledAt = o.scheduledAt;
      _expiresAt = o.expiresAt;
      _companyName = o.companyName;
    } else {
      _loadCompanyName();
    }
  }

  Future<void> _loadCompanyName() async {
    final uid = AuthService.uid;
    if (uid == null) return;
    final company = await CompanyService.get(uid);
    if (mounted && company != null) {
      setState(() => _companyName = company.name);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _originalCtrl.dispose();
    _discountedCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final b64 = await ImageHelper.pickAsBase64(source: source);
    if (b64 != null && mounted) setState(() => _imageBase64 = b64);
  }

  Future<void> _pickDateTime({required bool scheduled}) async {
    final now = DateTime.now();
    final base = scheduled ? (_scheduledAt ?? now) : (_expiresAt ?? now.add(const Duration(days: 7)));
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (!mounted) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    setState(() {
      if (scheduled) {
        _scheduledAt = picked;
      } else {
        _expiresAt = picked;
      }
    });
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBase64 == null) {
      _snack('Please add an offer image', AppColors.danger);
      return;
    }
    if (_expiresAt != null &&
        _expiresAt!.isBefore(_scheduledAt ?? DateTime.now())) {
      _snack('Expiry must be after the publish time', AppColors.danger);
      return;
    }

    setState(() => _saving = true);
    final uid = AuthService.uid;
    if (uid == null) return;

    final original = double.tryParse(_originalCtrl.text.trim());
    final discounted = double.tryParse(_discountedCtrl.text.trim());
    int? pct;
    if (original != null && discounted != null && original > 0 && discounted < original) {
      pct = (((original - discounted) / original) * 100).round();
    }

    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'imageBase64': _imageBase64,
        'category': _category,
        'originalPrice': original,
        'discountedPrice': discounted,
        'discountPercentage': pct,
        'promoCode': _promoCtrl.text.trim().isEmpty ? null : _promoCtrl.text.trim().toUpperCase(),
        'scheduledAt': _scheduledAt,
        'expiresAt': _expiresAt,
      };

      if (_isEditing) {
        // Firestore accepts DateTime values and stores them as Timestamps.
        await OfferService.update(widget.offer!.id, data);
      } else {
        final offer = Offer(
          id: '',
          companyId: uid,
          companyName: _companyName,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          imageBase64: _imageBase64,
          category: _category,
          originalPrice: original,
          discountedPrice: discounted,
          discountPercentage: pct,
          promoCode: _promoCtrl.text.trim().isEmpty
              ? null
              : _promoCtrl.text.trim().toUpperCase(),
          scheduledAt: _scheduledAt,
          expiresAt: _expiresAt,
        );
        await OfferService.create(offer);
      }

      if (!mounted) return;
      _snack(_isEditing ? 'Offer updated!' : 'Offer posted!', AppColors.success);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack('Failed: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Offer' : 'Post an Offer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageBase64 == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined,
                              size: 42, color: AppColors.primary),
                          const SizedBox(height: 10),
                          Text('Add offer image',
                              style: TextStyle(color: AppColors.subtleText(context))),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Base64Image(base64: _imageBase64),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text('Change',
                                      style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            _field(_titleCtrl, 'Offer title', Icons.title,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null),
            const SizedBox(height: 16),
            _field(_descCtrl, 'Description', Icons.notes,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a description' : null),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: _dec('Category', Icons.category_outlined),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Other'),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _field(_originalCtrl, 'Original ৳', Icons.sell_outlined,
                      keyboard: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_discountedCtrl, 'Now ৳', Icons.local_offer_outlined,
                      keyboard: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _field(_promoCtrl, 'Promo code (optional)', Icons.confirmation_number_outlined),
            const SizedBox(height: 20),

            // Scheduling
            _dateTile(
              icon: Icons.schedule,
              label: 'Publish',
              value: _scheduledAt == null ? 'Now' : _fmt(_scheduledAt!),
              onTap: () => _pickDateTime(scheduled: true),
              onClear: _scheduledAt == null ? null : () => setState(() => _scheduledAt = null),
            ),
            const SizedBox(height: 12),
            _dateTile(
              icon: Icons.event_busy,
              label: 'Expires',
              value: _expiresAt == null ? 'No expiry' : _fmt(_expiresAt!),
              onTap: () => _pickDateTime(scheduled: false),
              onClear: _expiresAt == null ? null : () => setState(() => _expiresAt = null),
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(_isEditing ? Icons.save : Icons.send),
                label: Text(_isEditing ? 'Save changes' : 'Post offer',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: _dec(label, icon),
      validator: validator,
    );
  }

  Widget _dateTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(value, style: TextStyle(color: AppColors.subtleText(context))),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              )
            else
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
