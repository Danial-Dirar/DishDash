import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/company_model.dart';
import '../../models/offer_model.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../services/location_service.dart';
import '../../services/offer_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/offer_card.dart';
import '../../utils/share_helper.dart';
import 'offer_detail_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final TabController _tabController;
  LatLng? _location;
  bool _isMapView = false;
  String _search = '';

  static const _fallback = LatLng(23.8103, 90.4125); // Dhaka

  String? get _uid => AuthService.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final pos = await LocationService.getCurrentLocationSafe();
    if (mounted && pos != null) {
      setState(() => _location = LatLng(pos.latitude, pos.longitude));
    }
  }

  void _openOffer(Offer offer) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer)),
    );
  }

  Future<void> _toggleSave(Offer offer, bool currentlySaved) async {
    final uid = _uid;
    if (uid == null) {
      _promptSignIn();
      return;
    }
    await OfferService.setSaved(uid, offer, !currentlySaved);
  }

  void _promptSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sign in to save offers'),
        action: SnackBarAction(
          label: 'Sign in',
          onPressed: () => Navigator.pushNamed(context, '/signin'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DishDash'),
        actions: [
          IconButton(
            tooltip: _isMapView ? 'List view' : 'Map view',
            icon: Icon(_isMapView ? Icons.view_list : Icons.map_outlined),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Explore'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      drawer: const AppDrawer(userType: 'user'),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isMapView ? _buildMap() : _buildExploreList(),
          _buildSaved(),
        ],
      ),
    );
  }

  // ---- Explore: list of live offers ----
  Widget _buildExploreList() {
    return StreamBuilder<List<Offer>>(
      stream: OfferService.streamActive(),
      builder: (context, offerSnap) {
        if (offerSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var offers = offerSnap.data ?? [];
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          offers = offers
              .where((o) =>
                  o.title.toLowerCase().contains(q) ||
                  o.companyName.toLowerCase().contains(q) ||
                  (o.category ?? '').toLowerCase().contains(q))
              .toList();
        }
        return Column(
          children: [
            _searchBar(),
            Expanded(
              child: offers.isEmpty
                  ? _empty(Icons.local_offer_outlined,
                      'No offers yet', 'Check back soon for tasty deals')
                  : StreamBuilder<Set<String>>(
                      stream: _uid == null
                          ? const Stream.empty()
                          : OfferService.savedIds(_uid!),
                      builder: (context, savedSnap) {
                        final saved = savedSnap.data ?? <String>{};
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: offers.length,
                          itemBuilder: (context, i) {
                            final o = offers[i];
                            return OfferCard(
                              offer: o,
                              isSaved: saved.contains(o.id),
                              onTap: () => _openOffer(o),
                              // Guests can share but not save.
                              onSave: _uid == null
                                  ? null
                                  : () => _toggleSave(o, saved.contains(o.id)),
                              onShare: () => ShareHelper.shareOffer(o),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Search offers or restaurants',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.surface(context),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---- Explore: map of restaurants ----
  Widget _buildMap() {
    final center = _location ?? _fallback;
    return StreamBuilder<List<Company>>(
      stream: CompanyService.streamAll(),
      builder: (context, snap) {
        final companies = (snap.data ?? [])
            .where((c) => c.hasLocation)
            .toList();
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: center, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.dish_dash',
                ),
                if (_location != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _location!,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ]),
                MarkerLayer(
                  markers: [
                    for (final c in companies)
                      Marker(
                        point: LatLng(c.latitude!, c.longitude!),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _showRestaurantSheet(c),
                          child: const Icon(Icons.location_on,
                              color: AppColors.primary, size: 42),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () => _mapController.move(center, 14),
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRestaurantSheet(Company c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Text(c.initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      if (c.location.isNotEmpty)
                        Text(c.location,
                            style: TextStyle(color: AppColors.subtleText(context))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (c.description.isNotEmpty) Text(c.description),
            if (c.cuisineTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final cuisine in c.cuisineTypes)
                    Chip(
                      label: Text(cuisine),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---- Saved tab ----
  Widget _buildSaved() {
    final uid = _uid;
    if (uid == null) {
      return _empty(Icons.lock_outline, 'Sign in required',
          'Sign in to keep your favourite offers here');
    }
    return StreamBuilder<List<Offer>>(
      stream: OfferService.streamSaved(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final offers = snap.data ?? [];
        if (offers.isEmpty) {
          return _empty(Icons.bookmark_border, 'No saved offers',
              'Tap the bookmark on any offer to save it');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: offers.length,
          itemBuilder: (context, i) {
            final o = offers[i];
            return OfferCard(
              offer: o,
              isSaved: true,
              onTap: () => _openOffer(o),
              onSave: () => _toggleSave(o, true),
              onShare: () => ShareHelper.shareOffer(o),
            );
          },
        );
      },
    );
  }

  Widget _empty(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
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
