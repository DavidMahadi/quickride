// lib/screens/user/user_home_screen.dart
import 'package:flutter/material.dart';
import 'package:swiftride/services/auth_service.dart';

const Color kNavy  = Color(0xFF0A0E21);
const Color kNavy2 = Color(0xFF12172E);
const Color kGold  = Color(0xFFD4A017);
const Color kGoldL = Color(0xFFE8C04A);
const Color kSurf  = Color(0xFF1A2035);
const Color kSurf2 = Color(0xFF222840);
const Color kText  = Color(0xFFEEEEF5);
const Color kTextS = Color(0xFF8A8FA8);

// Sample car data
final List<Map<String, dynamic>> kCars = [
  {'id': '1', 'name': 'Tesla Model S', 'brand': 'Tesla',   'category': 'Electric',  'price': 120, 'rating': 4.9, 'seats': 5, 'transmission': 'Auto', 'range': '405 mi', 'color': 0xFF1A237E},
  {'id': '2', 'name': 'BMW M5',        'brand': 'BMW',     'category': 'Sports',    'price': 150, 'rating': 4.8, 'seats': 5, 'transmission': 'Auto', 'range': '310 mi', 'color': 0xFF880E4F},
  {'id': '3', 'name': 'Range Rover',   'brand': 'Land Rover','category': 'SUV',     'price': 180, 'rating': 4.7, 'seats': 7, 'transmission': 'Auto', 'range': '350 mi', 'color': 0xFF1B5E20},
  {'id': '4', 'name': 'Audi A6',       'brand': 'Audi',    'category': 'Luxury',    'price': 130, 'rating': 4.6, 'seats': 5, 'transmission': 'Auto', 'range': '380 mi', 'color': 0xFF37474F},
  {'id': '5', 'name': 'Porsche 911',   'brand': 'Porsche', 'category': 'Sports',    'price': 200, 'rating': 5.0, 'seats': 2, 'transmission': 'Manual','range': '290 mi', 'color': 0xFF4E342E},
  {'id': '6', 'name': 'Mercedes GLE',  'brand': 'Mercedes','category': 'SUV',       'price': 160, 'rating': 4.8, 'seats': 7, 'transmission': 'Auto', 'range': '360 mi', 'color': 0xFF263238},
];

const List<String> kCategories = ['All', 'Electric', 'Sports', 'SUV', 'Luxury'];

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _tab      = 0;
  int _catIdx   = 0;
  final Set<String> _favs = {};

  List<Map<String, dynamic>> get _filtered {
    if (_catIdx == 0) return kCars;
    final cat = kCategories[_catIdx];
    return kCars.where((c) => c['category'] == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(
            filtered: _filtered,
            catIdx: _catIdx,
            favs: _favs,
            onCatChanged: (i) => setState(() => _catIdx = i),
            onFavToggle: (id) => setState(() => _favs.contains(id) ? _favs.remove(id) : _favs.add(id)),
          ),
          _SearchTab(onFavToggle: (id) => setState(() => _favs.contains(id) ? _favs.remove(id) : _favs.add(id)), favs: _favs),
          _BookingsTabPlaceholder(),
          _FavoritesTabPlaceholder(favs: _favs, cars: kCars),
          _ProfileTabPlaceholder(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _tab,
      onTap: (i) => setState(() => _tab = i),
      backgroundColor: kNavy2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kGold,
      unselectedItemColor: kTextS,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: kNavy2,
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 20),
          // Avatar + name
          CircleAvatar(
            radius: 36, backgroundColor: kGold,
            child: Text(
              (AuthService.userName.isNotEmpty ? AuthService.userName : 'User').split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
              style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          Text(AuthService.userName.isNotEmpty ? AuthService.userName : 'User',
              style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(AuthService.userEmail,
              style: const TextStyle(color: kTextS, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGold.withOpacity(0.3)),
            ),
            child: const Text('Premium Member', style: TextStyle(color: kGold, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          const Divider(color: kSurf2, height: 1),
          _DrawerItem(icon: Icons.home_rounded,         label: 'Home',         onTap: () { setState(() => _tab = 0); Navigator.pop(context); }),
          _DrawerItem(icon: Icons.search_rounded,       label: 'Search Cars',  onTap: () { setState(() => _tab = 1); Navigator.pop(context); }),
          _DrawerItem(icon: Icons.receipt_long_rounded, label: 'My Bookings',  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/user/my-bookings'); }),
          _DrawerItem(icon: Icons.favorite_rounded,     label: 'Favorites',    onTap: () { setState(() => _tab = 3); Navigator.pop(context); }),
          _DrawerItem(icon: Icons.message_rounded,      label: 'Messages',     onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/user/messages'); }),
          _DrawerItem(icon: Icons.person_rounded,       label: 'Profile',      onTap: () { setState(() => _tab = 4); Navigator.pop(context); }),
          _DrawerItem(icon: Icons.settings_rounded,     label: 'Settings',     onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/user/settings'); }),
          const Spacer(),
          const Divider(color: kSurf2, height: 1),
          _DrawerItem(
            icon: Icons.logout_rounded, label: 'Logout', color: const Color(0xFFFF4D6D),
            onTap: () {
              AuthService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
            },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final List<Map<String, dynamic>> filtered;
  final int catIdx;
  final Set<String> favs;
  final ValueChanged<int> onCatChanged;
  final ValueChanged<String> onFavToggle;

  const _HomeTab({
    required this.filtered, required this.catIdx, required this.favs,
    required this.onCatChanged, required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      // App bar
      SliverAppBar(
        pinned: true,
        backgroundColor: kNavy,
        expandedHeight: 160,
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: kText),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: kText), onPressed: () => Navigator.pushNamed(context, '/user/settings')),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/user/profile'),
              child: CircleAvatar(
                radius: 17, backgroundColor: kGold,
                child: Text(
                  (AuthService.userName.isNotEmpty ? AuthService.userName : 'User').split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Padding(
            padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Hi, ${AuthService.userName.split(' ').first}! 👋',
                    style: const TextStyle(color: kTextS, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('Find your perfect ride',
                    style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),

      // Search bar
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/user/home'),
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: kSurf2, borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: const Row(children: [
              Icon(Icons.search_rounded, color: kTextS, size: 20),
              SizedBox(width: 10),
              Text('Search cars, brands…', style: TextStyle(color: kTextS, fontSize: 14)),
            ]),
          ),
        ),
      )),

      // Category chips
      SliverToBoxAdapter(child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: kCategories.length,
          itemBuilder: (_, i) {
            final sel = i == catIdx;
            return GestureDetector(
              onTap: () => onCatChanged(i),
              child: Container(
                margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: sel ? kGold : kSurf2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: Text(kCategories[i],
                    style: TextStyle(
                        color: sel ? Colors.black : kTextS,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13))),
              ),
            );
          },
        ),
      )),

      // Featured header
      const SliverToBoxAdapter(child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Featured Cars', style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w700)),
          Text('See all', style: TextStyle(color: kGold, fontSize: 13)),
        ]),
      )),

      // Car grid
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12,
            mainAxisSpacing: 12, childAspectRatio: 0.76,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) => _CarCard(
              car: filtered[i],
              isFav: favs.contains(filtered[i]['id']),
              onFavToggle: () => onFavToggle(filtered[i]['id'] as String),
            ),
            childCount: filtered.length,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ]);
  }
}

// ─── Car Card ─────────────────────────────────────────────────
class _CarCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final bool isFav;
  final VoidCallback onFavToggle;
  const _CarCard({required this.car, required this.isFav, required this.onFavToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/user/car-detail', arguments: car),
      child: Container(
        decoration: BoxDecoration(color: kSurf, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Car thumbnail
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 110,
                width: double.infinity,
                color: Color(car['color'] as int),
                child: Icon(Icons.directions_car_rounded, size: 64, color: Colors.white.withOpacity(0.3)),
              ),
            ),
            Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: onFavToggle,
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? const Color(0xFFFF4D6D) : Colors.white, size: 16),
                ),
              )),
          ]),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(car['name'] as String,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.star_rounded, color: kGold, size: 13),
                const SizedBox(width: 3),
                Text('${car['rating']}', style: const TextStyle(color: kTextS, fontSize: 12)),
                const SizedBox(width: 6),
                Container(width: 3, height: 3, decoration: const BoxDecoration(color: kTextS, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Text(car['category'] as String,
                    style: const TextStyle(color: kTextS, fontSize: 12), overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: '\$${car['price']}',
                      style: const TextStyle(color: kGold, fontWeight: FontWeight.w800, fontSize: 15)),
                  const TextSpan(text: '/day', style: TextStyle(color: kTextS, fontSize: 11)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Book', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Search Tab (inline) ──────────────────────────────────────
class _SearchTab extends StatefulWidget {
  final Set<String> favs;
  final ValueChanged<String> onFavToggle;
  const _SearchTab({required this.favs, required this.onFavToggle});
  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _results = kCars;

  void _search(String q) {
    setState(() {
      _results = q.isEmpty
          ? kCars
          : kCars.where((c) =>
              (c['name'] as String).toLowerCase().contains(q.toLowerCase()) ||
              (c['brand'] as String).toLowerCase().contains(q.toLowerCase()) ||
              (c['category'] as String).toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 52),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _ctrl,
          onChanged: _search,
          style: const TextStyle(color: kText),
          decoration: InputDecoration(
            hintText: 'Search cars, brands…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded, color: kTextS),
                    onPressed: () { _ctrl.clear(); _search(''); })
                : null,
          ),
        ),
      ),
      Expanded(child: _results.isEmpty
          ? const Center(child: Text('No cars found', style: TextStyle(color: kTextS)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.76,
              ),
              itemCount: _results.length,
              itemBuilder: (_, i) => _CarCard(
                car: _results[i],
                isFav: widget.favs.contains(_results[i]['id']),
                onFavToggle: () => widget.onFavToggle(_results[i]['id'] as String),
              ),
            )),
    ]);
  }
}

// ─── Bottom tab placeholders that push to full screens ────────
class _BookingsTabPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, '/user/my-bookings');
    });
    return const SizedBox();
  }
}

class _FavoritesTabPlaceholder extends StatelessWidget {
  final Set<String> favs;
  final List<Map<String, dynamic>> cars;
  const _FavoritesTabPlaceholder({required this.favs, required this.cars});

  @override
  Widget build(BuildContext context) {
    final favCars = cars.where((c) => favs.contains(c['id'])).toList();
    return Scaffold(
      backgroundColor: kNavy,
      appBar: AppBar(title: const Text('Favorites')),
      body: favCars.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.favorite_border_rounded, color: kTextS, size: 60),
              const SizedBox(height: 16),
              const Text('No favorites yet', style: TextStyle(color: kTextS, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Tap ♡ on any car to save it here',
                  style: TextStyle(color: kTextS, fontSize: 13)),
            ]))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.76,
              ),
              itemCount: favCars.length,
              itemBuilder: (_, i) => _CarCard(
                car: favCars[i], isFav: true, onFavToggle: () {},
              ),
            ),
    );
  }
}

class _ProfileTabPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const UserProfileScreen();
  }
}

// ─── Helper widgets ───────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? kText;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w600)),
      onTap: onTap,
      dense: true,
    );
  }
}

// forward ref
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      Navigator.canPop(context)
          ? const SizedBox()
          : Container(color: kNavy);
}
