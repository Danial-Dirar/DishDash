import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../services/auth_service.dart';
import '../../services/menu_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_helper.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddSheet(context, uid),
        icon: const Icon(Icons.add),
        label: const Text('Add dish'),
      ),
      body: uid == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<List<MenuItem>>(
              stream: MenuService.stream(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('Your menu is empty',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Add dishes so customers know what you serve',
                            style: TextStyle(color: AppColors.subtleText(context))),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final m = items[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: Base64Image(
                          base64: m.imageBase64,
                          width: 56,
                          height: 56,
                          placeholderIcon: Icons.fastfood_outlined,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(m.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          m.description.isEmpty ? (m.category ?? '') : m.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (m.displayPrice.isNotEmpty)
                              Text(m.displayPrice,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              onPressed: () => MenuService.delete(uid, m.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showAddSheet(BuildContext context, String? uid) {
    if (uid == null) return;
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String? imageB64;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text('Add dish',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final b64 = await ImageHelper.pickAsBase64();
                    if (b64 != null) setSheet(() => imageB64 = b64);
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageB64 == null
                        ? const Center(
                            child: Icon(Icons.add_a_photo_outlined,
                                color: AppColors.primary, size: 32))
                        : Base64Image(base64: imageB64),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Dish name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Price ৳', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await MenuService.add(
                      uid,
                      MenuItem(
                        id: '',
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        price: double.tryParse(priceCtrl.text.trim()),
                        imageBase64: imageB64,
                      ),
                    );
                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                  child: const Text('Add to menu'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
