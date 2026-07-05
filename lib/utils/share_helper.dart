import 'package:share_plus/share_plus.dart';
import '../models/offer_model.dart';
import '../services/offer_service.dart';

/// Builds a friendly share message for an offer and records the share so it
/// shows up in the restaurant's analytics.
class ShareHelper {
  ShareHelper._();

  static Future<void> shareOffer(Offer offer) async {
    final buffer = StringBuffer()
      ..writeln('🍽️ ${offer.title} — ${offer.companyName}')
      ..writeln(offer.description);
    if (offer.displayDiscount.isNotEmpty) {
      buffer.writeln('🔥 ${offer.displayDiscount}');
    }
    if (offer.promoCode != null && offer.promoCode!.isNotEmpty) {
      buffer.writeln('Use code: ${offer.promoCode}');
    }
    buffer.write('\nShared via DishDash');

    await Share.share(buffer.toString());
    // Analytics write is best-effort — guests aren't allowed to write, so
    // swallow any permission error rather than surfacing it.
    try {
      await OfferService.incrementShare(offer.id);
    } catch (_) {}
  }
}
