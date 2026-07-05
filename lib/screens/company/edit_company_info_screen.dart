import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_helper.dart';

class EditCompanyInfoScreen extends StatefulWidget {
  const EditCompanyInfoScreen({super.key});

  @override
  State<EditCompanyInfoScreen> createState() => _EditCompanyInfoScreenState();
}

class _EditCompanyInfoScreenState extends State<EditCompanyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  String? _logoBase64;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = AuthService.uid;
    if (uid == null) return;
    final c = await CompanyService.get(uid);
    if (!mounted) return;
    if (c != null) {
      _nameCtrl.text = c.name;
      _descCtrl.text = c.description;
      _locationCtrl.text = c.location;
      _contactCtrl.text = c.contact ?? '';
      _websiteCtrl.text = c.website ?? '';
      _logoBase64 = c.logoBase64;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = AuthService.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await CompanyService.update(uid, {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'contact': _contactCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
        'logoBase64': _logoBase64,
      });
      // Keep the display name in sync with the restaurant name.
      await AuthService.updateProfile(name: _nameCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Restaurant info saved'),
            backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Info')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withValues(alpha: 0.15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Base64Image(
                            base64: _logoBase64,
                            width: 110,
                            height: 110,
                            placeholderIcon: Icons.storefront,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final b64 = await ImageHelper.pickAsBase64(
                                  maxWidth: 500, quality: 60);
                              if (b64 != null) setState(() => _logoBase64 = b64);
                            },
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _field(_nameCtrl, 'Restaurant name', Icons.store,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null),
                  const SizedBox(height: 16),
                  _field(_descCtrl, 'Description', Icons.description_outlined,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _field(_locationCtrl, 'Location', Icons.location_on_outlined),
                  const SizedBox(height: 16),
                  _field(_contactCtrl, 'Contact number', Icons.phone_outlined,
                      keyboard: TextInputType.phone),
                  const SizedBox(height: 16),
                  _field(_websiteCtrl, 'Website', Icons.web_outlined,
                      keyboard: TextInputType.url),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save changes',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

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
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
