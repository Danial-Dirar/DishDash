import 'package:flutter/material.dart';
import '../../models/company_model.dart';
import '../../models/offer_model.dart';
import '../../services/auth_service.dart';
import '../../services/company_service.dart';
import '../../services/offer_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_drawer.dart';
import 'post_offer_screen.dart';

class CompanyDashboardScreen extends StatelessWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Restaurant info',
            onPressed: () => Navigator.pushNamed(context, '/editcompanyinfo'),
          ),
        ],
      ),
      drawer: const AppDrawer(userType: 'company'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostOfferScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Offer'),
      ),
      body: uid == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<List<Offer>>(
              stream: OfferService.streamByCompany(uid),
              builder: (context, snap) {
                final offers = snap.data ?? [];
                final analytics = CompanyAnalytics.from(offers);
                final loading =
                    snap.connectionState == ConnectionState.waiting;
                return RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      _Header(uid: uid),
                      const SizedBox(height: 20),
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        _statsGrid(analytics),
                        const SizedBox(height: 24),
                        _quickActions(context),
                        const SizedBox(height: 24),
                        _topOffers(context, offers),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _statsGrid(CompanyAnalytics a) {
    final tiles = [
      _StatData('Total Views', a.totalViews, Icons.visibility_outlined,
          AppColors.info),
      _StatData('Total Saves', a.totalSaves, Icons.bookmark_outline,
          AppColors.primary),
      _StatData('Shares', a.totalShares, Icons.share_outlined, AppColors.success),
      _StatData('Active Offers', a.activeOffers, Icons.local_offer_outlined,
          AppColors.warning),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [for (final t in tiles) _statCard(t)],
    );
  }

  Widget _statCard(_StatData t) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(t.icon, color: t.color, size: 20),
                ),
                Text('${t.value}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(
              t.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subtleText(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      (_Act('Post Offer', Icons.add_business_outlined, AppColors.primary), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PostOfferScreen()));
      }),
      (_Act('My Offers', Icons.article_outlined, AppColors.info), () {
        Navigator.pushNamed(context, '/myposts');
      }),
      (_Act('Menu', Icons.restaurant_menu_outlined, AppColors.success), () {
        Navigator.pushNamed(context, '/menu');
      }),
      (_Act('Edit Info', Icons.edit_outlined, AppColors.warning), () {
        Navigator.pushNamed(context, '/editcompanyinfo');
      }),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final a in actions)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: a.$2,
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: a.$1.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(a.$1.icon, color: a.$1.color),
                        ),
                        const SizedBox(height: 6),
                        Text(a.$1.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _topOffers(BuildContext context, List<Offer> offers) {
    final top = [...offers]..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    final show = top.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Top Performing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/myposts'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (show.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(Icons.insights_outlined, size: 44, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('Post an offer to start tracking performance',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subtleText(context))),
              ],
            ),
          )
        else
          for (final o in show)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(o.statusLabel,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.subtleText(context))),
                      ],
                    ),
                  ),
                  _mini(Icons.visibility_outlined, o.viewCount),
                  _mini(Icons.bookmark_outline, o.saveCount),
                  _mini(Icons.share_outlined, o.shareCount),
                ],
              ),
            ),
      ],
    );
  }

  Widget _mini(IconData icon, int v) => Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.grey),
            const SizedBox(width: 3),
            Text('$v', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _Header extends StatelessWidget {
  final String uid;
  const _Header({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Company?>(
      stream: CompanyService.stream(uid),
      builder: (context, snap) {
        final name = snap.data?.name ?? 'Your Restaurant';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back 👋',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'Track how your offers are performing and reach more customers.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  _StatData(this.label, this.value, this.icon, this.color);
}

class _Act {
  final String label;
  final IconData icon;
  final Color color;
  _Act(this.label, this.icon, this.color);
}
