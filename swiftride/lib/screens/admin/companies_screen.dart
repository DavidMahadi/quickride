import 'package:flutter/material.dart';
import 'package:swiftride/screens/guest/home_screen.dart';
import 'package:swiftride/screens/guest/car_detail_screen.dart';
import 'package:swiftride/screens/guest/app_shell.dart';
import 'package:swiftride/screens/guest/shared_drawer.dart';
import 'package:swiftride/screens/user/fleet_screen.dart';
import 'package:swiftride/screens/user/booking_screen.dart';

// ═══════════════════════════════════════════════════════════════
//  DATA MODEL
// ═══════════════════════════════════════════════════════════════
class RentalCompany {
  final String id, name, initials, tagline, location, phone, email, website;
  final double rating;
  final int totalRentals, reviewCount, yearsActive;
  final Color brandColor;
  final List<String> categories;
  final List<CompanyCar> fleet;
  final List<CompanyRequirement> requirements;
  final List<CompanyPolicy> policies;
  final String rentalModel; // 'Daily' | 'Monthly' | 'Long-Term' | 'Hybrid'

  const RentalCompany({
    required this.id,
    required this.name,
    required this.initials,
    required this.tagline,
    required this.location,
    required this.phone,
    required this.email,
    required this.website,
    required this.rating,
    required this.totalRentals,
    required this.reviewCount,
    required this.yearsActive,
    required this.brandColor,
    required this.categories,
    required this.fleet,
    required this.requirements,
    required this.policies,
    this.rentalModel = 'Daily',
  });
}

class CompanyCar {
  final String name, category, fuel, transmission;
  final double price;        // daily price
  final double monthlyPrice; // per month (0 = not offered)
  final double longTermPrice;// per month for 6+ months (0 = not offered)
  final int seats;
  final bool available;
  const CompanyCar({
    required this.name, required this.category, required this.fuel,
    required this.transmission, required this.price, required this.seats,
    this.monthlyPrice = 0, this.longTermPrice = 0,
    this.available = true,
  });
}

class CompanyRequirement {
  final IconData icon;
  final String title, description;
  final bool mandatory;
  const CompanyRequirement({
    required this.icon, required this.title,
    required this.description, this.mandatory = true,
  });
}

class CompanyPolicy {
  final IconData icon;
  final String title, detail;
  const CompanyPolicy({required this.icon, required this.title, required this.detail});
}

// ═══════════════════════════════════════════════════════════════
//  COMPANIES DATA
// ═══════════════════════════════════════════════════════════════
final List<RentalCompany> allCompanies = [

  RentalCompany(
    id: 'drivekigali',
    name: 'DriveKigali',
    initials: 'DK',
    tagline: 'Kigali\'s most trusted car rental since 2017',
    location: 'KG 7 Ave, Kiyovu, Kigali',
    phone: '+250 788 100 200',
    email: 'hello@drivekigali.rw',
    website: 'www.drivekigali.rw',
    rating: 4.9,
    totalRentals: 1240,
    reviewCount: 312,
    yearsActive: 7,
    brandColor: Color(0xFF1D9E75),
    categories: ['Economy', 'SUV', 'Sedan'],
    rentalModel: 'Daily',
    requirements: [
      CompanyRequirement(icon: Icons.badge_outlined,        title: 'Valid Driver\'s License', description: 'Must be valid for at least 6 months from rental date. International licenses accepted.'),
      CompanyRequirement(icon: Icons.credit_card_outlined,  title: 'National ID or Passport', description: 'Original document required at pickup. Photocopies not accepted.'),
      CompanyRequirement(icon: Icons.cake_outlined,         title: 'Minimum Age: 21',          description: 'Drivers must be at least 21 years old. Drivers under 25 incur a young driver surcharge.'),
      CompanyRequirement(icon: Icons.payments_outlined,     title: 'Security Deposit',         description: 'RWF 100,000 or equivalent held on card at pickup. Released within 3 business days after return.'),
      CompanyRequirement(icon: Icons.phone_outlined,        title: 'Valid Phone Number',       description: 'A working local or international phone number for communication during the rental.', mandatory: false),
    ],
    policies: [
      CompanyPolicy(icon: Icons.local_gas_station_outlined, title: 'Fuel Policy',      detail: 'Full-to-full. Return the car with the same fuel level as pickup or a refuelling fee applies.'),
      CompanyPolicy(icon: Icons.schedule_outlined,          title: 'Late Return',       detail: 'Grace period of 1 hour. After that, a full extra day is charged.'),
      CompanyPolicy(icon: Icons.cancel_outlined,            title: 'Cancellation',      detail: 'Free cancellation up to 24 hours before pickup. Within 24 hours: 50% of booking value charged.'),
      CompanyPolicy(icon: Icons.health_and_safety_outlined, title: 'Insurance',         detail: 'Basic CDW included. Full coverage upgrade available at RWF 8,000/day.'),
      CompanyPolicy(icon: Icons.map_outlined,               title: 'Mileage',           detail: 'Unlimited mileage within Rwanda. Cross-border trips require prior approval and extra fees apply.'),
    ],
    fleet: [
      CompanyCar(name: 'Volkswagen Golf',  category: 'Economy', fuel: 'Petrol', transmission: 'Manual', price: 38,  seats: 5),
      CompanyCar(name: 'Hyundai i10',      category: 'Economy', fuel: 'Petrol', transmission: 'Manual', price: 30,  seats: 5),
      CompanyCar(name: 'Toyota RAV4',      category: 'SUV',     fuel: 'Petrol', transmission: 'Auto',   price: 60,  seats: 5),
      CompanyCar(name: 'Toyota Camry',     category: 'Sedan',   fuel: 'Petrol', transmission: 'Auto',   price: 45,  seats: 5),
    ],
  ),

  RentalCompany(
    id: 'safariwheels',
    name: 'SafariWheels',
    initials: 'SW',
    tagline: 'Premium 4x4s for every adventure',
    location: 'KN 3 Rd, Remera, Kigali',
    phone: '+250 788 200 300',
    email: 'bookings@safariwheels.rw',
    website: 'www.safariwheels.rw',
    rating: 4.8,
    totalRentals: 870,
    reviewCount: 198,
    yearsActive: 5,
    brandColor: Color(0xFF3B5FD4),
    categories: ['SUV', 'Luxury', '4x4'],
    rentalModel: 'Monthly',
    requirements: [
      CompanyRequirement(icon: Icons.badge_outlined,       title: 'Valid Driver\'s License', description: 'Must be valid. International Driving Permit required for non-East African license holders.'),
      CompanyRequirement(icon: Icons.credit_card_outlined, title: 'National ID or Passport', description: 'Original required. Must match the name on the booking.'),
      CompanyRequirement(icon: Icons.cake_outlined,        title: 'Minimum Age: 23',          description: 'All drivers must be at least 23 years old. No young driver surcharge.'),
      CompanyRequirement(icon: Icons.payments_outlined,    title: 'Security Deposit',         description: 'USD 200 or equivalent. Credit card hold only — cash not accepted for deposit.'),
      CompanyRequirement(icon: Icons.verified_user_outlined, title: 'Clean Driving Record',  description: 'No major traffic violations in the past 3 years. May be verified.', mandatory: false),
    ],
    policies: [
      CompanyPolicy(icon: Icons.local_gas_station_outlined, title: 'Fuel Policy',      detail: 'Full-to-full. Fuel top-up service available at RWF 500/litre above pump price.'),
      CompanyPolicy(icon: Icons.schedule_outlined,          title: 'Late Return',       detail: 'RWF 5,000 per hour late. After 3 hours late, a full day is charged.'),
      CompanyPolicy(icon: Icons.cancel_outlined,            title: 'Cancellation',      detail: 'Free up to 48 hours before pickup. 48–24 hours: 25% fee. Under 24 hours: no refund.'),
      CompanyPolicy(icon: Icons.health_and_safety_outlined, title: 'Insurance',         detail: 'Comprehensive insurance included for all vehicles. No additional CDW required.'),
      CompanyPolicy(icon: Icons.map_outlined,               title: 'Cross-Border',      detail: 'Uganda, Tanzania, and DRC permitted with advance notice. Additional fee of USD 30/day applies.'),
    ],
    fleet: [
      CompanyCar(name: 'Hyundai Tucson',    category: 'SUV',     fuel: 'Petrol', transmission: 'Auto', price: 58, seats: 5),
      CompanyCar(name: 'Mitsubishi Pajero', category: '4x4',     fuel: 'Diesel', transmission: 'Auto', price: 65, seats: 7),
      CompanyCar(name: 'BMW 5 Series',      category: 'Luxury',  fuel: 'Petrol', transmission: 'Auto', price: 90, seats: 5),
      CompanyCar(name: 'Land Cruiser V8',   category: '4x4',     fuel: 'Diesel', transmission: 'Auto', price: 120, seats: 8, available: false),
    ],
  ),

  RentalCompany(
    id: 'luxdrive',
    name: 'LuxDrive',
    initials: 'LD',
    tagline: 'Arrive in style. Every time.',
    location: 'KG 11 Ave, Nyarutarama, Kigali',
    phone: '+250 788 300 400',
    email: 'vip@luxdrive.rw',
    website: 'www.luxdrive.rw',
    rating: 4.9,
    totalRentals: 540,
    reviewCount: 142,
    yearsActive: 4,
    brandColor: Color(0xFF7F77DD),
    categories: ['Luxury', 'Premium'],
    rentalModel: 'Long-Term',
    requirements: [
      CompanyRequirement(icon: Icons.badge_outlined,        title: 'Valid Driver\'s License', description: 'Minimum 3 years driving experience. International license mandatory for non-Rwandan residents.'),
      CompanyRequirement(icon: Icons.credit_card_outlined,  title: 'Passport',                description: 'Passport required for all bookings. National ID accepted only for Rwandan nationals.'),
      CompanyRequirement(icon: Icons.cake_outlined,         title: 'Minimum Age: 25',          description: 'Drivers must be 25 or older. No exceptions for luxury fleet.'),
      CompanyRequirement(icon: Icons.payments_outlined,     title: 'Security Deposit',         description: 'USD 500 credit card hold required. Debit cards not accepted.'),
      CompanyRequirement(icon: Icons.verified_outlined,     title: 'Identity Verification',    description: 'Online identity check completed at least 24 hours before pickup via our app or email link.'),
    ],
    policies: [
      CompanyPolicy(icon: Icons.local_gas_station_outlined, title: 'Fuel Policy',      detail: 'Full-to-full. Premium fuel only (95 octane or higher). Incorrect fuel usage voids insurance.'),
      CompanyPolicy(icon: Icons.schedule_outlined,          title: 'Late Return',       detail: 'No grace period. RWF 15,000 per hour. Vehicles must be returned to the same location.'),
      CompanyPolicy(icon: Icons.cancel_outlined,            title: 'Cancellation',      detail: 'Free cancellation 72+ hours before pickup. Within 72 hours: full charge. No-shows: full charge.'),
      CompanyPolicy(icon: Icons.health_and_safety_outlined, title: 'Insurance',         detail: 'Full comprehensive coverage with zero excess included in all bookings.'),
      CompanyPolicy(icon: Icons.drive_eta_outlined,         title: 'Chauffeur Option',  detail: 'Professional driver available at RWF 30,000/day. Advance booking of 24 hours required.'),
    ],
    fleet: [
      CompanyCar(name: 'Mercedes C-Class', category: 'Luxury',  fuel: 'Diesel', transmission: 'Auto', price: 95,  seats: 5),
      CompanyCar(name: 'Audi A6',          category: 'Luxury',  fuel: 'Petrol', transmission: 'Auto', price: 100, seats: 5),
      CompanyCar(name: 'Lexus RX',         category: 'Premium', fuel: 'Hybrid', transmission: 'Auto', price: 110, seats: 5),
      CompanyCar(name: 'BMW 7 Series',     category: 'Premium', fuel: 'Petrol', transmission: 'Auto', price: 140, seats: 5, available: false),
    ],
  ),

  RentalCompany(
    id: 'rwandaride',
    name: 'RwandaRide',
    initials: 'RR',
    tagline: 'Affordable wheels across Rwanda',
    location: 'KK 15 Rd, Kicukiro, Kigali',
    phone: '+250 788 400 500',
    email: 'info@rwandaride.rw',
    website: 'www.rwandaride.rw',
    rating: 4.6,
    totalRentals: 690,
    reviewCount: 175,
    yearsActive: 6,
    brandColor: Color(0xFFD85A30),
    categories: ['Economy', 'SUV', 'Van'],
    rentalModel: 'Hybrid',
    requirements: [
      CompanyRequirement(icon: Icons.badge_outlined,       title: 'Valid Driver\'s License', description: 'Any valid license accepted. Learner\'s permits not accepted.'),
      CompanyRequirement(icon: Icons.credit_card_outlined, title: 'National ID or Passport', description: 'Any valid government-issued photo ID accepted at pickup.'),
      CompanyRequirement(icon: Icons.cake_outlined,        title: 'Minimum Age: 20',          description: 'Minimum age is 20. Young driver surcharge of RWF 5,000/day for drivers under 23.'),
      CompanyRequirement(icon: Icons.payments_outlined,    title: 'Security Deposit',         description: 'RWF 80,000 deposit. Cash, card, or mobile money accepted.'),
    ],
    policies: [
      CompanyPolicy(icon: Icons.local_gas_station_outlined, title: 'Fuel Policy',   detail: 'Full-to-full. Pay-as-you-go option available — we top up and charge at pump price.'),
      CompanyPolicy(icon: Icons.schedule_outlined,          title: 'Late Return',    detail: '2-hour grace period. After grace period, hourly rate applies up to one full day charge.'),
      CompanyPolicy(icon: Icons.cancel_outlined,            title: 'Cancellation',   detail: 'Full refund if cancelled 12+ hours before. Under 12 hours: RWF 20,000 cancellation fee.'),
      CompanyPolicy(icon: Icons.health_and_safety_outlined, title: 'Insurance',      detail: 'Third-party insurance included. CDW available at RWF 6,000/day.'),
    ],
    fleet: [
      CompanyCar(name: 'Toyota Corolla',  category: 'Economy', fuel: 'Petrol', transmission: 'Auto',   price: 32, seats: 5),
      CompanyCar(name: 'Honda CR-V',      category: 'SUV',     fuel: 'Petrol', transmission: 'Auto',   price: 55, seats: 5),
      CompanyCar(name: 'Ford Transit',    category: 'Van',     fuel: 'Diesel', transmission: 'Manual', price: 75, seats: 12),
    ],
  ),

  RentalCompany(
    id: 'vango',
    name: 'VanGo',
    initials: 'VG',
    tagline: 'Group travel made easy',
    location: 'KN 78 St, Gisozi, Kigali',
    phone: '+250 788 500 600',
    email: 'fleet@vango.rw',
    website: 'www.vango.rw',
    rating: 4.5,
    totalRentals: 320,
    reviewCount: 88,
    yearsActive: 3,
    brandColor: Color(0xFF0D7EA8),
    categories: ['Van', 'Minibus'],
    rentalModel: 'Daily',
    requirements: [
      CompanyRequirement(icon: Icons.badge_outlined,         title: 'Professional License',   description: 'PSV (Public Service Vehicle) license required for vans with 9+ seats. Regular license for smaller vans.'),
      CompanyRequirement(icon: Icons.credit_card_outlined,   title: 'National ID or Passport',description: 'Required. Must be the same person driving.'),
      CompanyRequirement(icon: Icons.cake_outlined,          title: 'Minimum Age: 23',         description: 'Minimum 23 years old and at least 2 years of driving experience.'),
      CompanyRequirement(icon: Icons.payments_outlined,      title: 'Security Deposit',        description: 'RWF 150,000 for vans, RWF 200,000 for minibuses. Card or mobile money.'),
      CompanyRequirement(icon: Icons.group_outlined,         title: 'Passenger List',          description: 'For bookings of 9+ seats, a passenger manifest must be submitted 24 hours before departure.', mandatory: false),
    ],
    policies: [
      CompanyPolicy(icon: Icons.local_gas_station_outlined, title: 'Fuel Policy',    detail: 'Full-to-full. Diesel only fleet. Do not use petrol.'),
      CompanyPolicy(icon: Icons.schedule_outlined,          title: 'Late Return',     detail: 'RWF 8,000 per hour after agreed return time. Advance extensions can be arranged by phone.'),
      CompanyPolicy(icon: Icons.cancel_outlined,            title: 'Cancellation',    detail: 'Free up to 48 hours before. 24–48 hours: 30% fee. Less than 24 hours: 60% fee.'),
      CompanyPolicy(icon: Icons.health_and_safety_outlined, title: 'Insurance',       detail: 'Comprehensive group-travel insurance included. Covers up to 15 passengers.'),
      CompanyPolicy(icon: Icons.drive_eta_outlined,         title: 'Driver Service',  detail: 'Experienced van drivers available at RWF 25,000/day including fuel surcharge.'),
    ],
    fleet: [
      CompanyCar(name: 'Toyota Hiace',       category: 'Van',     fuel: 'Diesel', transmission: 'Manual', price: 70, seats: 12),
      CompanyCar(name: 'Mercedes Sprinter',  category: 'Van',     fuel: 'Diesel', transmission: 'Manual', price: 85, seats: 15),
      CompanyCar(name: 'Toyota Coaster',     category: 'Minibus', fuel: 'Diesel', transmission: 'Manual', price: 110, seats: 29),
      CompanyCar(name: 'Rosa Minibus',       category: 'Minibus', fuel: 'Diesel', transmission: 'Manual', price: 130, seats: 35, available: false),
    ],
  ),
];

// ── Dynamically registered companies (added by super admin) ──
// Super admin registration appends here. Client view merges both.
final List<RentalCompany> registeredCompanies = [];

/// All companies visible to clients = static seed + super-admin registered.
List<RentalCompany> get allCompaniesWithDynamic =>
    [...allCompanies, ...registeredCompanies];

// ═══════════════════════════════════════════════════════════════
//  COMPANIES LIST SCREEN
// ═══════════════════════════════════════════════════════════════
class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});
  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<RentalCompany> get _filtered => _filter.isEmpty
      ? allCompaniesWithDynamic
      : allCompaniesWithDynamic.where((c) =>
          c.name.toLowerCase().contains(_filter) ||
          c.categories.any((cat) => cat.toLowerCase().contains(_filter)) ||
          c.location.toLowerCase().contains(_filter)).toList();

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    final results = _filtered;

    return Scaffold(
      backgroundColor: bg,
      drawer: const AppDrawer(activeTab: 0),
      bottomNavigationBar: AppBottomNav(activeIndex: 0),
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textPri, size: 20), onPressed: () => Navigator.of(context).maybePop()),
        title: Text('Rental Companies',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPri)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.tune, color: textPri, size: 20),
          ),
        ],
      ),
      body: Column(children: [

        // ── Search ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _filter = v.toLowerCase()),
            style: TextStyle(color: textPri, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search companies…',
              hintStyle: TextStyle(color: textSec, fontSize: 13),
              prefixIcon: Icon(Icons.search, color: textSec, size: 20),
              suffixIcon: _filter.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: textSec, size: 18),
                      onPressed: () => setState(() { _searchCtrl.clear(); _filter = ''; }),
                    )
                  : null,
              filled: true, fillColor: surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border, width: 0.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.gold, width: 1)),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),

        // ── Count ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(children: [
            Text('${results.length} companies',
                style: TextStyle(fontSize: 12, color: textSec)),
          ]),
        ),

        // ── List ──
        Expanded(
          child: results.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.business_outlined, size: 48, color: textSec),
                  const SizedBox(height: 12),
                  Text('No companies found', style: TextStyle(color: textSec, fontSize: 15)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _CompanyCard(
                    company: results[i],
                    isDark: isDark,
                    border: border,
                    textPri: textPri,
                    textSec: textSec,
                  ),
                ),
        ),
      ]),
    );
  }
}

// ── Company list card ─────────────────────────────────────────────────────────
class _CompanyCard extends StatelessWidget {
  final RentalCompany company;
  final bool isDark;
  final Color border, textPri, textSec;
  const _CompanyCard({required this.company, required this.isDark, required this.border, required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) {
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => CompanyDetailScreen(company: company),
      )),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Top row: avatar + name + rating
          Row(children: [
            // Brand avatar
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: company.brandColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: company.brandColor.withOpacity(0.3), width: 1),
              ),
              child: Center(child: Text(company.initials,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: company.brandColor))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(company.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
              const SizedBox(height: 3),
              Text(company.tagline,
                  style: TextStyle(fontSize: 11, color: textSec),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.star, color: AppColors.gold, size: 13),
                const SizedBox(width: 3),
                Text(company.rating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri)),
                Text(' (${company.reviewCount})',
                    style: TextStyle(fontSize: 11, color: textSec)),
                const SizedBox(width: 10),
                Icon(Icons.directions_car_outlined, size: 12, color: textSec),
                const SizedBox(width: 3),
                Text('${company.fleet.length} cars',
                    style: TextStyle(fontSize: 11, color: textSec)),
              ]),
            ])),
            Icon(Icons.chevron_right, color: textSec, size: 20),
          ]),

          const SizedBox(height: 12),

          // Stats row
          Row(children: [
            _StatChip(label: '${company.totalRentals}+ Rentals', icon: Icons.check_circle_outline, color: company.brandColor),
            const SizedBox(width: 8),
            _StatChip(label: '${company.yearsActive} yrs active', icon: Icons.schedule_outlined, color: company.brandColor),
            const SizedBox(width: 8),
            _StatChip(label: company.categories.first, icon: Icons.local_offer_outlined, color: company.brandColor),
          ]),

          const SizedBox(height: 12),

          // Location
          Row(children: [
            Icon(Icons.location_on_outlined, size: 13, color: textSec),
            const SizedBox(width: 4),
            Expanded(child: Text(company.location,
                style: TextStyle(fontSize: 11, color: textSec),
                overflow: TextOverflow.ellipsis)),
          ]),

          const SizedBox(height: 10),

          // Category tags
          Wrap(spacing: 6, children: company.categories.map((cat) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: company.brandColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: company.brandColor.withOpacity(0.25), width: 0.5),
            ),
            child: Text(cat,
                style: TextStyle(fontSize: 10, color: company.brandColor, fontWeight: FontWeight.w600)),
          )).toList()),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  const _StatChip({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
//  COMPANY DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════
class CompanyDetailScreen extends StatefulWidget {
  final RentalCompany company;
  const CompanyDetailScreen({super.key, required this.company});
  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c       = widget.company;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.darkBg      : AppColors.lightBg;
    final card    = isDark ? AppColors.darkCard    : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder  : const Color(0xFFDDE1EE);
    final textPri = isDark ? Colors.white           : const Color(0xFF0A0E1A);
    final textSec = isDark ? const Color(0xFF8B91A8): const Color(0xFF6B7280);

    final availableCount = c.fleet.where((car) => car.available).length;
    final minPrice = c.fleet.map((car) => car.price).reduce((a, b) => a < b ? a : b).round();

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        // CTA bar
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: bg,
            border: Border(top: BorderSide(color: border, width: 0.5)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$availableCount cars available',
                  style: TextStyle(fontSize: 12, color: textSec)),
              Text('from \$$minPrice/day',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
            ])),
            const SizedBox(width: 16),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FleetScreen(company: c))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: c.brandColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Browse Fleet',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ]),
              ),
            )),
          ]),
        ),
      ]),
      body: Column(children: [

        // ── App bar ──────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: c.brandColor.withOpacity(isDark ? 0.15 : 0.08),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(children: [
              // Decorative circles
              Positioned(top: -20, right: -20,
                child: Container(width: 140, height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.brandColor.withOpacity(0.07)))),
              Positioned(bottom: 0, left: -30,
                child: Container(width: 100, height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.brandColor.withOpacity(0.05)))),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Top row: back + share
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                  child: Row(children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textPri, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.ios_share_outlined, color: textPri, size: 20),
                      onPressed: () {},
                    ),
                  ]),
                ),

                // Logo + name
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                        color: c.brandColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: c.brandColor.withOpacity(0.4), width: 1.5),
                      ),
                      child: Center(child: Text(c.initials,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900, color: c.brandColor))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800, color: textPri)),
                      const SizedBox(height: 4),
                      Text(c.tagline,
                          style: TextStyle(fontSize: 12, color: textSec, height: 1.4),
                          maxLines: 2),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 13),
                        const SizedBox(width: 3),
                        Text(c.rating.toStringAsFixed(1),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPri)),
                        Text('  ·  ${c.reviewCount} reviews',
                            style: TextStyle(fontSize: 11, color: textSec)),
                      ]),
                    ])),
                  ]),
                ),
              ]),
            ]),
          ),
        ),

        // ── Stats bar ────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Row(children: [
            _StatBox(value: c.rating.toStringAsFixed(1), label: 'Rating',       color: c.brandColor, textPri: textPri, textSec: textSec),
            _VDivider(border: border),
            _StatBox(value: '${c.reviewCount}',          label: 'Reviews',      color: c.brandColor, textPri: textPri, textSec: textSec),
            _VDivider(border: border),
            _StatBox(value: '${c.totalRentals}+',        label: 'Rentals',      color: c.brandColor, textPri: textPri, textSec: textSec),
            _VDivider(border: border),
            _StatBox(value: '${c.yearsActive} yrs',      label: 'Active',       color: c.brandColor, textPri: textPri, textSec: textSec),
          ]),
        ),

        // ── Rental model banner ──────────────────────────────────
        _RentalModelBanner(
          rentalModel: c.rentalModel,
          brandColor: c.brandColor,
          border: border,
          textPri: textPri,
          textSec: textSec,
        ),

        // ── Contact info ─────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Column(children: [
            _ContactRow(icon: Icons.location_on_outlined, label: c.location, color: c.brandColor, textPri: textPri, textSec: textSec, border: border),
            _ContactRow(icon: Icons.phone_outlined,       label: c.phone,    color: c.brandColor, textPri: textPri, textSec: textSec, border: border),
            _ContactRow(icon: Icons.email_outlined,       label: c.email,    color: c.brandColor, textPri: textPri, textSec: textSec, border: border),
            _ContactRow(icon: Icons.language_outlined,    label: c.website,  color: c.brandColor, textPri: textPri, textSec: textSec, border: border, isLast: true),
          ]),
        ),

        // ── Tabs ─────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: border, width: 0.5)),
          ),
          child: TabBar(
            controller: _tab,
            indicatorColor: c.brandColor,
            labelColor: c.brandColor,
            unselectedLabelColor: textSec,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Fleet'),
              Tab(text: 'Requirements'),
              Tab(text: 'Policies'),
            ],
          ),
        ),

        // ── Tab content ──────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _FleetTab(
                  company: c, isDark: isDark,
                  card: card, border: border,
                  surface: surface, textPri: textPri, textSec: textSec),
              _RequirementsTab(
                  company: c, card: card,
                  border: border, textPri: textPri, textSec: textSec),
              _PoliciesTab(
                  company: c, card: card,
                  border: border, textPri: textPri, textSec: textSec),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Fleet tab ─────────────────────────────────────────────────────────────────
class _FleetTab extends StatelessWidget {
  final RentalCompany company;
  final bool isDark;
  final Color card, border, surface, textPri, textSec;
  const _FleetTab({required this.company, required this.isDark,
      required this.card, required this.border, required this.surface,
      required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: company.fleet.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final car = company.fleet[i];
        return GestureDetector(
          onTap: car.available ? () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => CarDetailScreen(
              carName:      car.name,
              company:      company.name,
              price:        '\$${car.price.round()}',
              category:     car.category,
              rating:       company.rating,
              reviews:      company.reviewCount,
              seats:        car.seats,
              fuel:         car.fuel,
              transmission: car.transmission,
            ),
          )) : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: car.available ? border : border.withOpacity(0.4),
                  width: 0.5),
            ),
            child: Row(children: [
              // Car icon
              Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  color: company.brandColor.withOpacity(car.available ? 0.1 : 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.directions_car,
                    color: company.brandColor.withOpacity(car.available ? 0.9 : 0.25),
                    size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(car.name,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: car.available ? textPri : textPri.withOpacity(0.4)))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: car.available
                          ? const Color(0xFF1D9E75).withOpacity(0.1)
                          : Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      car.available ? 'Available' : 'Unavailable',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: car.available
                              ? const Color(0xFF1D9E75)
                              : Colors.redAccent),
                    ),
                  ),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  _MiniChip(icon: Icons.people_outline,             label: '${car.seats} seats', textSec: textSec),
                  const SizedBox(width: 8),
                  _MiniChip(icon: Icons.settings_outlined,          label: car.transmission,     textSec: textSec),
                  const SizedBox(width: 8),
                  _MiniChip(icon: Icons.local_gas_station_outlined, label: car.fuel,             textSec: textSec),
                ]),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: company.brandColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(car.category,
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: company.brandColor)),
                ),
              ])),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('\$${car.price.round()}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: AppColors.gold)),
                Text('/day', style: TextStyle(fontSize: 10, color: textSec)),
                if (car.available) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: company.brandColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          carName: car.name, company: company.name,
                          price: '\$${car.price.round()}',
                          category: car.category, seats: car.seats,
                          fuel: car.fuel, transmission: car.transmission,
                          rentalModel: company.rentalModel,
                          monthlyPrice: car.monthlyPrice,
                          longTermPrice: car.longTermPrice,
                        ))),
                      child: const Text('Book',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ]),
            ]),
          ),
        );
      },
    );
  }
}

// ── Requirements tab ──────────────────────────────────────────────────────────
class _RequirementsTab extends StatelessWidget {
  final RentalCompany company;
  final Color card, border, textPri, textSec;
  const _RequirementsTab({required this.company, required this.card,
      required this.border, required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: company.brandColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: company.brandColor.withOpacity(0.25), width: 0.5),
          ),
          child: Row(children: [
            Icon(Icons.info_outline, color: company.brandColor, size: 17),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'All mandatory requirements must be presented at pickup. Missing documents will result in cancellation without refund.',
              style: TextStyle(fontSize: 11, color: textSec, height: 1.4),
            )),
          ]),
        ),

        // Mandatory
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('MANDATORY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: textSec, letterSpacing: .6)),
        ),
        ...company.requirements.where((r) => r.mandatory).map((r) =>
            _ReqCard(req: r, company: company, card: card, border: border,
                textPri: textPri, textSec: textSec)),

        if (company.requirements.any((r) => !r.mandatory)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
            child: Text('OPTIONAL / RECOMMENDED',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: textSec, letterSpacing: .6)),
          ),
          ...company.requirements.where((r) => !r.mandatory).map((r) =>
              _ReqCard(req: r, company: company, card: card, border: border,
                  textPri: textPri, textSec: textSec)),
        ],
      ],
    );
  }
}

class _ReqCard extends StatelessWidget {
  final CompanyRequirement req;
  final RentalCompany company;
  final Color card, border, textPri, textSec;
  const _ReqCard({required this.req, required this.company, required this.card,
      required this.border, required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: card, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border, width: 0.5),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: company.brandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(req.icon, color: company.brandColor, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(req.title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri))),
          if (req.mandatory)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Required',
                  style: TextStyle(fontSize: 9, color: Colors.redAccent,
                      fontWeight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 5),
        Text(req.description,
            style: TextStyle(fontSize: 12, color: textSec, height: 1.5)),
      ])),
    ]),
  );
}

// ── Policies tab ──────────────────────────────────────────────────────────────
class _PoliciesTab extends StatelessWidget {
  final RentalCompany company;
  final Color card, border, textPri, textSec;
  const _PoliciesTab({required this.company, required this.card,
      required this.border, required this.textPri, required this.textSec});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
    itemCount: company.policies.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (_, i) {
      final p = company.policies[i];
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: company.brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(p.icon, color: company.brandColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
            const SizedBox(height: 6),
            Text(p.detail,
                style: TextStyle(fontSize: 12, color: textSec, height: 1.5)),
          ])),
        ]),
      );
    },
  );
}

// ── Shared small widgets ──────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color, textPri, textSec;
  const _StatBox({required this.value, required this.label,
      required this.color, required this.textPri, required this.textSec});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    const SizedBox(height: 3),
    Text(label, style: TextStyle(fontSize: 10, color: textSec)),
  ]));
}

class _VDivider extends StatelessWidget {
  final Color border;
  const _VDivider({required this.border});
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: border);
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, textPri, textSec, border;
  final bool isLast;
  const _ContactRow({required this.icon, required this.label, required this.color,
      required this.textPri, required this.textSec, required this.border,
      this.isLast = false});
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: textPri))),
      ]),
    ),
    if (!isLast) Divider(color: border, height: 1),
  ]);
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textSec;
  const _MiniChip({required this.icon, required this.label, required this.textSec});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: textSec),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 11, color: textSec)),
  ]);
}

// ═══════════════════════════════════════════════════════════════
//  RENTAL MODEL BANNER
// ═══════════════════════════════════════════════════════════════
class _RentalModelBanner extends StatelessWidget {
  final String rentalModel;
  final Color brandColor, border, textPri, textSec;
  const _RentalModelBanner({
    required this.rentalModel, required this.brandColor,
    required this.border, required this.textPri, required this.textSec,
  });

  IconData get _icon {
    switch (rentalModel) {
      case 'Monthly':   return Icons.calendar_month_rounded;
      case 'Long-Term': return Icons.event_repeat_rounded;
      case 'Hybrid':    return Icons.swap_horiz_rounded;
      default:          return Icons.today_rounded;
    }
  }

  String get _title {
    switch (rentalModel) {
      case 'Monthly':   return 'Monthly Rental';
      case 'Long-Term': return 'Long-Term Rental (6+ months)';
      case 'Hybrid':    return 'Hybrid Rental';
      default:          return 'Daily Rental';
    }
  }

  String get _desc {
    switch (rentalModel) {
      case 'Monthly':
        return 'This company rents by the month. You\'ll choose how many months when booking. Best for extended stays and corporate use.';
      case 'Long-Term':
        return 'Minimum rental is 6 months. Ideal for expats, long projects, and annual contracts with significant discounts.';
      case 'Hybrid':
        return 'Flexible pricing — you can choose daily or monthly when booking. Mix and match based on your needs.';
      default:
        return 'This company rents by the day. Pick your start and end dates and you\'re ready to go.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brandColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brandColor.withOpacity(0.3), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: brandColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(_icon, color: brandColor, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(_title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: brandColor)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: brandColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6)),
              child: Text(rentalModel,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: brandColor)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(_desc,
              style: TextStyle(fontSize: 11, color: textSec, height: 1.4)),
          if (rentalModel == 'Hybrid') ...[
            const SizedBox(height: 6),
            Row(children: [
              _HybridTag(label: 'Daily rates', icon: Icons.today_rounded, color: brandColor),
              const SizedBox(width: 8),
              _HybridTag(label: 'Monthly rates', icon: Icons.calendar_month_rounded, color: brandColor),
            ]),
          ],
        ])),
      ]),
    );
  }
}

class _HybridTag extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  const _HybridTag({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 11),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}
