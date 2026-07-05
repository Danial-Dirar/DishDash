import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../utils/app_colors.dart';
import '../utils/image_helper.dart';

/// Rich offer card used across foodie-facing screens (feed + saved).
class OfferCard extends StatelessWidget {
  final Offer offer;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const OfferCard({
    super.key,
    required this.offer,
    this.isSaved = false,
    this.onTap,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Base64Image(
                  base64: offer.imageBase64,
                  height: 160,
                  width: double.infinity,
                ),
                if (offer.displayDiscount.isNotEmpty)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(offer.displayDiscount,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                if (onSave != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? AppColors.secondary : Colors.white,
                        ),
                        onPressed: onSave,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(offer.companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.subtleText(context))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(offer.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(offer.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.subtleText(context))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (offer.displayPrice.isNotEmpty) ...[
                        Text(offer.displayPrice,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        if (offer.originalPrice != null &&
                            offer.discountedPrice != null) ...[
                          const SizedBox(width: 8),
                          Text('৳${offer.originalPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 13)),
                        ],
                      ],
                      const Spacer(),
                      if (offer.timeRemaining.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 3),
                            Text(offer.timeRemaining,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      if (onShare != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.share_outlined, size: 20),
                          onPressed: onShare,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
