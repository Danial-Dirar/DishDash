import 'package:flutter/material.dart';
import '../../models/offer_model.dart';
import '../../services/auth_service.dart';
import '../../services/offer_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_helper.dart';
import 'post_offer_screen.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  Color _statusColor(OfferStatus s) => switch (s) {
        OfferStatus.active => AppColors.success,
        OfferStatus.scheduled => AppColors.info,
        OfferStatus.expired => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostOfferScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: uid == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<List<Offer>>(
              stream: OfferService.streamByCompany(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final offers = snap.data ?? [];
                if (offers.isEmpty) return const _EmptyState();
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _offerCard(context, offers[i]),
                );
              },
            ),
    );
  }

  Widget _offerCard(BuildContext context, Offer o) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Base64Image(base64: o.imageBase64, width: 96, height: 96),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              o.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _chip(o.statusLabel, _statusColor(o.status)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        o.description,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.subtleText(context)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (o.timeRemaining.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(o.timeRemaining,
                            style: TextStyle(
                                fontSize: 11,
                                color: _statusColor(o.status),
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _stat(Icons.visibility_outlined, o.viewCount, 'views'),
                _stat(Icons.bookmark_outline, o.saveCount, 'saves'),
                _stat(Icons.share_outlined, o.shareCount, 'shares'),
                const Spacer(),
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PostOfferScreen(offer: o)),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.danger),
                  onPressed: () => _confirmDelete(context, o),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, int value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text('$value',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );

  void _confirmDelete(BuildContext context, Offer o) {
    showDialog(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Delete offer?'),
        content: Text('"${o.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dctx);
              await OfferService.delete(o.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No offers yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tap “New” to post your first offer',
              style: TextStyle(color: AppColors.subtleText(context))),
        ],
      ),
    );
  }
}
