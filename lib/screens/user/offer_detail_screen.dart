import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/offer_model.dart';
import '../../services/auth_service.dart';
import '../../services/offer_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_helper.dart';
import '../../utils/share_helper.dart';

class OfferDetailScreen extends StatefulWidget {
  final Offer? offer;
  const OfferDetailScreen({super.key, this.offer});

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  Offer? _offer;

  @override
  void initState() {
    super.initState();
    _offer = widget.offer;
    // Count the view once the detail screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final o = _offer ??
          (ModalRoute.of(context)?.settings.arguments as Offer?);
      _offer ??= o;
      // Only signed-in users may write; guest view writes would be denied.
      if (o != null && AuthService.uid != null) {
        OfferService.incrementView(o.id);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final offer = _offer ??
        (ModalRoute.of(context)?.settings.arguments as Offer?);
    if (offer == null) {
      return const Scaffold(body: Center(child: Text('Offer not found')));
    }
    final uid = AuthService.uid;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Base64Image(
                base64: offer.imageBase64,
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => ShareHelper.shareOffer(offer),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(offer.companyName,
                          style: TextStyle(
                              color: AppColors.subtleText(context),
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (offer.displayDiscount.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(offer.displayDiscount,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(offer.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (offer.displayPrice.isNotEmpty)
                    Row(
                      children: [
                        Text(offer.displayPrice,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        if (offer.originalPrice != null &&
                            offer.discountedPrice != null) ...[
                          const SizedBox(width: 10),
                          Text('৳${offer.originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 16)),
                        ],
                      ],
                    ),
                  const SizedBox(height: 16),
                  Text(offer.description,
                      style: const TextStyle(fontSize: 15, height: 1.5)),
                  const SizedBox(height: 20),
                  if (offer.promoCode != null && offer.promoCode!.isNotEmpty)
                    _promoBox(context, offer.promoCode!),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoPill(Icons.schedule,
                          offer.timeRemaining.isEmpty ? offer.statusLabel : offer.timeRemaining),
                      const SizedBox(width: 10),
                      _infoPill(Icons.bookmark_outline, '${offer.saveCount} saved'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (uid == null)
                    // Guests can share but not save.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => ShareHelper.shareOffer(offer),
                        icon: const Icon(Icons.share),
                        label: const Text('Share this offer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  else
                    StreamBuilder<Set<String>>(
                      stream: OfferService.savedIds(uid),
                      builder: (context, snap) {
                        final saved = snap.data?.contains(offer.id) ?? false;
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    OfferService.setSaved(uid, offer, !saved),
                                icon: Icon(saved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border),
                                label: Text(saved ? 'Saved' : 'Save offer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      saved ? AppColors.secondary : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => ShareHelper.shareOffer(offer),
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('Share'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoBox(BuildContext context, String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            style: BorderStyle.solid),
        color: AppColors.primary.withValues(alpha: 0.06),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined,
              color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(code,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.5)),
          ),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Promo code copied')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String text) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.subtleText(context)),
            const SizedBox(width: 5),
            Text(text, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
