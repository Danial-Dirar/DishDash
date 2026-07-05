import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/offer_model.dart';

/// Aggregated business metrics computed from a restaurant's offers.
class CompanyAnalytics {
  final int totalOffers;
  final int activeOffers;
  final int scheduledOffers;
  final int expiredOffers;
  final int totalViews;
  final int totalSaves;
  final int totalShares;

  const CompanyAnalytics({
    this.totalOffers = 0,
    this.activeOffers = 0,
    this.scheduledOffers = 0,
    this.expiredOffers = 0,
    this.totalViews = 0,
    this.totalSaves = 0,
    this.totalShares = 0,
  });

  factory CompanyAnalytics.from(List<Offer> offers) {
    var active = 0, scheduled = 0, expired = 0, views = 0, saves = 0, shares = 0;
    for (final o in offers) {
      switch (o.status) {
        case OfferStatus.active:
          active++;
        case OfferStatus.scheduled:
          scheduled++;
        case OfferStatus.expired:
          expired++;
      }
      views += o.viewCount;
      saves += o.saveCount;
      shares += o.shareCount;
    }
    return CompanyAnalytics(
      totalOffers: offers.length,
      activeOffers: active,
      scheduledOffers: scheduled,
      expiredOffers: expired,
      totalViews: views,
      totalSaves: saves,
      totalShares: shares,
    );
  }
}

class OfferService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('offers');

  static Future<String> create(Offer offer) async {
    final ref = await _col.add(offer.toCreateMap());
    return ref.id;
  }

  static Future<void> update(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  static Future<void> delete(String id) => _col.doc(id).delete();

  /// Live stream of one restaurant's offers, newest first.
  static Stream<List<Offer>> streamByCompany(String companyId) {
    return _col.where('companyId', isEqualTo: companyId).snapshots().map((s) {
      final list = s.docs.map(Offer.fromDoc).toList();
      list.sort(
        (a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      return list;
    });
  }

  /// Live, currently-active offers for foodies (scheduled/expired filtered out).
  static Stream<List<Offer>> streamActive() {
    return _col.snapshots().map((s) {
      final list = s.docs.map(Offer.fromDoc).where((o) => o.isLive).toList();
      list.sort(
        (a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      return list;
    });
  }

  static Future<void> incrementView(String id) =>
      _col.doc(id).update({'viewCount': FieldValue.increment(1)});

  static Future<void> incrementShare(String id) =>
      _col.doc(id).update({'shareCount': FieldValue.increment(1)});

  // ---- Saves: users/{uid}/saved/{offerId} ----

  static DocumentReference<Map<String, dynamic>> _savedRef(
    String uid,
    String offerId,
  ) => _db.collection('users').doc(uid).collection('saved').doc(offerId);

  static Future<void> setSaved(String uid, Offer offer, bool save) async {
    if (save) {
      await _savedRef(uid, offer.id).set(offer.toSavedMap());
      await _col.doc(offer.id).update({'saveCount': FieldValue.increment(1)});
    } else {
      await _savedRef(uid, offer.id).delete();
      await _col.doc(offer.id).update({'saveCount': FieldValue.increment(-1)});
    }
  }

  /// The set of offer ids the foodie has saved (for toggling save icons).
  static Stream<Set<String>> savedIds(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toSet());
  }

  /// Full saved offers list, rendered from denormalized copies.
  static Stream<List<Offer>> streamSaved(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved')
        .snapshots()
        .map((s) {
          final list = s.docs.map((d) => Offer.fromMap(d.id, d.data())).toList();
          list.sort((a, b) => b.id.compareTo(a.id));
          return list;
        });
  }
}
