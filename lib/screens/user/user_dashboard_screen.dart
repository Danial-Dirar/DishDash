import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/app_drawer.dart';
import '../../models/company_model.dart';
import '../../models/offer_model.dart';
import '../../services/location_service.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen>
    with TickerProviderStateMixin {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Set<Marker> markers = {};
  List<Company> nearbyRestaurants = [];
  List<Offer> featuredOffers = [];
  bool isLoading = true;
  bool isMapView = true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _initializeLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
      _loadNearbyRestaurants();
      _loadFeaturedOffers();
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showLocationError(e.toString());
    }
  }

  void _loadNearbyRestaurants() {
    // TODO: Fetch from API
    // Mock data for now
    nearbyRestaurants = [
      Company(
        id: 1,
        name: 'Pizza Palace',
        description: 'Best pizza in town',
        location: 'Downtown',
        logoUrl: 'https://example.com/pizza.jpg',
        latitude: currentLocation!.latitude + 0.001,
        longitude: currentLocation!.longitude + 0.001,
        rating: 4.5,
        cuisineTypes: ['Italian', 'Pizza'],
      ),
      Company(
        id: 2,
        name: 'Burger Barn',
        description: 'Juicy burgers and fries',
        location: 'Main Street',
        logoUrl: 'https://example.com/burger.jpg',
        latitude: currentLocation!.latitude - 0.002,
        longitude: currentLocation!.longitude + 0.002,
        rating: 4.2,
        cuisineTypes: ['American', 'Burgers'],
      ),
    ];
    _updateMapMarkers();
  }

  void _loadFeaturedOffers() {
    // TODO: Fetch from API
    // Mock data for now
    featuredOffers = [
      Offer(
        id: 1,
        title: '50% Off Pizza',
        description: 'Get 50% off on all large pizzas',
        imageUrl: 'https://example.com/offer1.jpg',
        companyId: 1,
        originalPrice: 20.0,
        discountedPrice: 10.0,
        discountPercentage: 50,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
      Offer(
        id: 2,
        title: 'Buy 1 Get 1 Free',
        description: 'Buy one burger get one free',
        imageUrl: 'https://example.com/offer2.jpg',
        companyId: 2,
        expiresAt: DateTime.now().add(const Duration(days: 3)),
      ),
    ];
  }

  void _updateMapMarkers() {
    markers.clear();
    for (var restaurant in nearbyRestaurants) {
      if (restaurant.latitude != null && restaurant.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(restaurant.id.toString()),
            position: LatLng(restaurant.latitude!, restaurant.longitude!),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet: '${restaurant.displayRating} ⭐ • ${restaurant.location}',
              onTap: () => _showRestaurantDetails(restaurant),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  void _showLocationError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: Text('Failed to get your location: $error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeLocation();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRestaurantDetails(Company restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFFF6B35),
                      child: Text(
                        restaurant.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            restaurant.location,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(' ${restaurant.displayRating}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  restaurant.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (restaurant.cuisineTypes?.isNotEmpty ?? false) ...[
                  const Text(
                    'Cuisine Types:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: restaurant.cuisineTypes!
                        .map(
                          (cuisine) => Chip(
                            label: Text(cuisine),
                            backgroundColor: const Color(
                              0xFFFF6B35,
                            ).withOpacity(0.1),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/restaurant-offers',
                        arguments: restaurant,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Offers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (controller) {
        mapController = controller;
      },
      initialCameraPosition: CameraPosition(target: currentLocation!, zoom: 14),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      compassEnabled: true,
      onTap: (LatLng position) {
        // Handle map tap
      },
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _initializeLocation,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Featured Offers Section
          const Text(
            'Featured Offers',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featuredOffers.length,
              itemBuilder: (context, index) {
                final offer = featuredOffers[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF6B35).withOpacity(0.8),
                                const Color(0xFFF7931E).withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                offer.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const Spacer(),
                              if (offer.displayDiscount.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    offer.displayDiscount,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF6B35),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                offer.timeRemaining,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Nearby Restaurants Section
          const Text(
            'Nearby Restaurants',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nearbyRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = nearbyRestaurants[index];
              final distance = currentLocation != null && restaurant.hasLocation
                  ? restaurant.distanceFrom(
                      currentLocation!.latitude,
                      currentLocation!.longitude,
                    )
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFFF6B35),
                    child: Text(
                      restaurant.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.description),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${restaurant.displayRating}'),
                          if (distance != null) ...[
                            const Text(' • '),
                            Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            Text(
                              ' ${LocationService.formatDistance(distance)}',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showRestaurantDetails(restaurant),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('DishDash'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                isMapView = !isMapView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
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
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF6B35)),
                  SizedBox(height: 16),
                  Text('Finding amazing offers near you...'),
                ],
              ),
            )
          : currentLocation == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Location not available',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enable location services',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeLocation,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Explore Tab
                FadeTransition(
                  opacity: _animation,
                  child: isMapView ? _buildMapView() : _buildListView(),
                ),
                // Saved Tab
                const Center(
                  child: Text(
                    'Saved offers will appear here',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
      floatingActionButton: currentLocation != null && isMapView
          ? FloatingActionButton(
              onPressed: () {
                mapController?.animateCamera(
                  CameraUpdate.newLatLng(currentLocation!),
                );
              },
              backgroundColor: const Color(0xFFFF6B35),
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }
}
