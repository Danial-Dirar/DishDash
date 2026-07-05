import 'package:flutter/material.dart';
import '../../models/offer_model.dart';
import '../../services/auth_service.dart';
import '../../services/offer_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/share_helper.dart';
import '../../widgets/offer_card.dart';
import 'offer_detail_screen.dart';

/// Standalone list of the signed-in foodie's saved offers (drawer entry).
class OfferListScreen extends StatelessWidget {
  const OfferListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Offers')),
      body: uid == null
          ? _empty(context, Icons.lock_outline, 'Sign in required',
              'Sign in to keep your favourite offers here')
          : StreamBuilder<List<Offer>>(
              stream: OfferService.streamSaved(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final offers = snap.data ?? [];
                if (offers.isEmpty) {
                  return _empty(context, Icons.bookmark_border,
                      'No saved offers', 'Tap the bookmark on any offer to save it');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: offers.length,
                  itemBuilder: (context, i) {
                    final o = offers[i];
                    return OfferCard(
                      offer: o,
                      isSaved: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => OfferDetailScreen(offer: o)),
                      ),
                      onSave: () => OfferService.setSaved(uid, o, false),
                      onShare: () => ShareHelper.shareOffer(o),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _empty(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.subtleText(context))),
          ],
        ),
      ),
    );
  }
}
