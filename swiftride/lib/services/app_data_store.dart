// lib/services/app_data_store.dart
// ─────────────────────────────────────────────────────────────
//  SwiftRide — Central In-Memory Data Store
//
//  Single source of truth for ALL mutable app data.
//  Every model has every field needed for DB mapping.
//  Every mutation is logged in the audit trail.
//  Replace _seed() data with API calls when connecting backend.
// ─────────────────────────────────────────────────────────────
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ═════════════════════════════════════════════════════════════
//  AUDIT LOG
// ═════════════════════════════════════════════════════════════
class AuditEntry {
  final String id, actor, actorRole, company, action, category, timestamp;
  const AuditEntry({
    required this.id, required this.actor, required this.actorRole,
    required this.company, required this.action,
    required this.category, required this.timestamp,
  });
}

// ═════════════════════════════════════════════════════════════
//  USER MODEL
// ═════════════════════════════════════════════════════════════
class UserModel {
  String id, name, email, phone, role, status;
  String? company;         // null for clients; company name for staff/admin
  String? avatarInitials;
  int trips;
  double spent;
  String memberSince;
  String driverLicense;
  String address;
  String dateOfBirth;
  bool isVerified;
  String lastUpdatedBy, lastUpdatedAt;

  UserModel({
    required this.id, required this.name, required this.email,
    required this.phone, required this.role, required this.status,
    this.company, String? avatarInitials,
    this.trips = 0, this.spent = 0.0,
    this.memberSince = '', this.driverLicense = '',
    this.address = '', this.dateOfBirth = '',
    this.isVerified = false,
    this.lastUpdatedBy = '', this.lastUpdatedAt = '',
  }) : avatarInitials = avatarInitials ??
           (name.split(' ').map((e) => e.isEmpty ? '' : e[0]).take(2).join());

  // DB-ready map
  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'email': email, 'phone': phone,
    'role': role, 'status': status, 'company': company,
    'trips': trips, 'spent': spent, 'memberSince': memberSince,
    'driverLicense': driverLicense, 'address': address,
    'dateOfBirth': dateOfBirth, 'isVerified': isVerified,
  };
}

// ═════════════════════════════════════════════════════════════
//  CAR MODEL
// ═════════════════════════════════════════════════════════════
class SharedCar {
  String id, name, brand, category, fuel, transmission, company;
  String year, description, imageUrl;
  int seats;
  double price, rating;
  int color;                 // ARGB int for Color(car['color'])
  bool available;
  String rentalModel;        // 'Daily' | 'Monthly' | 'Long-Term' | 'Hybrid'
  double monthlyPrice, longTermPrice;
  String lastUpdatedBy, lastUpdatedAt;

  SharedCar({
    required this.id, required this.name, required this.brand,
    required this.category, required this.price, required this.seats,
    required this.transmission, required this.fuel, required this.company,
    this.year = '', this.description = '', this.imageUrl = '',
    this.color = 0xFF37474F, this.rating = 4.5,
    this.available = true, this.rentalModel = 'Daily',
    this.monthlyPrice = 0, this.longTermPrice = 0,
    this.lastUpdatedBy = '', this.lastUpdatedAt = '',
  });

  // Compatibility map for screens that use car['field'] notation
  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'brand': brand, 'year': year,
    'category': category, 'price': price.toInt(), 'rating': rating,
    'seats': seats, 'transmission': transmission, 'fuel': fuel,
    'range': '', 'color': color, 'desc': description,
    'company': company, 'available': available,
  };
}

// ═════════════════════════════════════════════════════════════
//  BOOKING MODEL
// ═════════════════════════════════════════════════════════════
class SharedBooking {
  String id;                 // UUID for DB primary key
  final String ref;          // human-readable SR reference
  String customerId, customerName, customerPhone;
  String carId, carName, carBrand, carCategory;
  int carColor, carSeats;
  String carFuel, carTransmission, carYear;
  String companyId, companyName;
  String pickupDate, returnDate;
  String pickupLocation, dropoffLocation;
  int days;
  double pricePerDay, subtotal, serviceFee, insurance, total;
  String paymentMethod;      // 'Credit Card' | 'MTN Mobile Money' | 'Airtel Money' | 'Cash'
  String paymentReference;   // card last4, phone number, etc.
  String status;             // 'Active' | 'Upcoming' | 'Completed' | 'Cancelled'
  bool termsAgreed;
  String createdAt, lastUpdatedBy, lastUpdatedAt;

  SharedBooking({
    required this.id, required this.ref,
    required this.customerId, required this.customerName,
    required this.customerPhone,
    required this.carId, required this.carName, required this.carBrand,
    required this.carCategory, required this.carColor, required this.carSeats,
    required this.carFuel, required this.carTransmission, required this.carYear,
    required this.companyId, required this.companyName,
    required this.pickupDate, required this.returnDate,
    required this.pickupLocation, required this.dropoffLocation,
    required this.days, required this.pricePerDay,
    required this.subtotal, required this.serviceFee,
    required this.insurance, required this.total,
    required this.paymentMethod, required this.status,
    this.paymentReference = '', this.termsAgreed = true,
    this.createdAt = '', this.lastUpdatedBy = '', this.lastUpdatedAt = '',
  });

  // Compatibility getters used by older screens
  String get from => pickupDate;
  String get to   => returnDate;
  String get car  => carName;
  String get company => companyName;
  String get customer => customerName;
  double get amount => total;

  Map<String, dynamic> toMap() => {
    'id': id, 'ref': ref,
    'customerId': customerId, 'customerName': customerName,
    'customerPhone': customerPhone,
    'carId': carId, 'carName': carName, 'carBrand': carBrand,
    'carCategory': carCategory, 'carColor': carColor, 'carSeats': carSeats,
    'carFuel': carFuel, 'carTransmission': carTransmission, 'carYear': carYear,
    'companyId': companyId, 'companyName': companyName,
    'pickupDate': pickupDate, 'returnDate': returnDate,
    'pickupLocation': pickupLocation, 'dropoffLocation': dropoffLocation,
    'days': days, 'pricePerDay': pricePerDay, 'subtotal': subtotal,
    'serviceFee': serviceFee, 'insurance': insurance, 'total': total,
    'paymentMethod': paymentMethod, 'paymentReference': paymentReference,
    'status': status, 'termsAgreed': termsAgreed, 'createdAt': createdAt,
  };
}

// ═════════════════════════════════════════════════════════════
//  REVIEW MODEL
// ═════════════════════════════════════════════════════════════
class SharedReview {
  final String id, bookingRef, customerId, customerName;
  final String companyId, companyName, carId, carName;
  final int rating;
  final String comment;
  final String createdAt;
  String reply;
  String replyAt;

  SharedReview({
    required this.id, required this.bookingRef,
    required this.customerId, required this.customerName,
    required this.companyId, required this.companyName,
    required this.carId, required this.carName,
    required this.rating, required this.comment, required this.createdAt,
    this.reply = '', this.replyAt = '',
  });
}

// ═════════════════════════════════════════════════════════════
//  TEAM MEMBER / AGENT MODEL
// ═════════════════════════════════════════════════════════════
class TeamMember {
  String id, name, email, phone, role;
  String companyId, companyName;
  bool isActive;
  String joinedAt, lastUpdatedBy, lastUpdatedAt;

  TeamMember({
    required this.id, required this.name, required this.email,
    required this.phone, required this.role,
    required this.companyId, required this.companyName,
    this.isActive = true, this.joinedAt = '',
    this.lastUpdatedBy = '', this.lastUpdatedAt = '',
  });
}

// ═════════════════════════════════════════════════════════════
//  COMPANY MODEL
// ═════════════════════════════════════════════════════════════
class SharedCompany {
  String id, name, status, location;
  String adminId, adminName, adminEmail, phone, regNumber;
  String email, website;
  String rentalModel;       // 'Daily' | 'Monthly' | 'Long-Term' | 'Hybrid'
  double commissionPct;
  int agents, cars, bookings;
  double revenue, rating;
  List<String> categories;
  bool documentsVerified;
  String approvedAt, lastUpdatedBy, lastUpdatedAt;

  SharedCompany({
    required this.id, required this.name, required this.status,
    required this.location, required this.adminName, required this.adminEmail,
    required this.phone, required this.regNumber,
    this.adminId = '', this.email = '', this.website = '',
    this.rentalModel = 'Daily', this.commissionPct = 10.0,
    this.agents = 0, this.cars = 0, this.bookings = 0,
    this.revenue = 0, this.rating = 0,
    this.categories = const [],
    this.documentsVerified = false,
    this.approvedAt = '', this.lastUpdatedBy = '', this.lastUpdatedAt = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'status': status, 'location': location,
    'adminName': adminName, 'adminEmail': adminEmail, 'phone': phone,
    'regNumber': regNumber, 'email': email, 'website': website,
    'rentalModel': rentalModel, 'commissionPct': commissionPct,
    'agents': agents, 'cars': cars, 'bookings': bookings,
    'revenue': revenue, 'rating': rating,
  };
}

// ═════════════════════════════════════════════════════════════
//  NOTIFICATION MODEL
// ═════════════════════════════════════════════════════════════
class AppNotification {
  final String id, title, body, type, targetUserId, targetRole;
  bool isRead;
  final String createdAt;

  AppNotification({
    required this.id, required this.title, required this.body,
    required this.type, required this.targetUserId, required this.targetRole,
    this.isRead = false, required this.createdAt,
  });
}

// ═════════════════════════════════════════════════════════════
//  THE STORE
// ═════════════════════════════════════════════════════════════
// ── Chat message model ─────────────────────────────────────────
class ChatMessage {
  final String id, text, senderId, senderName;
  final bool isFromUser;
  final DateTime timestamp;
  ChatMessage({
    required this.id, required this.text,
    required this.senderId, required this.senderName,
    required this.isFromUser, DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${timestamp.day}/${timestamp.month}';
  }
}

// ── User activity model ────────────────────────────────────────
class UserActivity {
  final String id, userId, title, subtitle, icon, category;
  final DateTime timestamp;
  UserActivity({
    required this.id, required this.userId,
    required this.title, required this.subtitle,
    required this.icon, required this.category,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

class AppDataStore extends ChangeNotifier {
  static final AppDataStore instance = AppDataStore._();
  AppDataStore._() { _seed(); }

  // ── Collections ────────────────────────────────────────────
  final List<AuditEntry>      auditLog      = [];
  final List<UserModel>       users         = [];
  final List<SharedCompany>   companies     = [];
  final List<SharedCar>       cars          = [];
  final List<SharedBooking>   bookings      = [];
  final List<SharedReview>    reviews       = [];
  final List<TeamMember>      teamMembers   = [];
  final List<AppNotification> notifications = [];

  // ── Chat messages per company ──────────────────────────────
  // Key: companyName → list of chat messages
  final Map<String, List<ChatMessage>> chats = {};

  void addChatMessage(String companyName, ChatMessage msg) {
    chats.putIfAbsent(companyName, () => []);
    chats[companyName]!.add(msg);
    notifyListeners();
  }

  List<ChatMessage> chatWith(String companyName) =>
      chats[companyName] ?? [];

  /// Returns all companies the user has chatted with, newest first
  List<String> get chatCompanies {
    final entries = chats.entries.where((e) => e.value.isNotEmpty).toList();
    entries.sort((a, b) =>
        b.value.last.timestamp.compareTo(a.value.last.timestamp));
    return entries.map((e) => e.key).toList();
  }

  // ── User activity log ──────────────────────────────────────
  final List<UserActivity> userActivity = [];

  void addUserActivity(UserActivity activity) {
    userActivity.insert(0, activity);
    if (userActivity.length > 100) userActivity.removeLast();
    notifyListeners();
  }

  List<UserActivity> activitiesForUser(String userId) =>
      userActivity.where((a) => a.userId == userId).toList();

  // ── Audit log ───────────────────────────────────────────────
  void _log(String actor, String actorRole, String company,
      String action, String category) {
    auditLog.insert(0, AuditEntry(
      id: 'AL${auditLog.length + 1}',
      actor: actor, actorRole: actorRole, company: company,
      action: action, category: category, timestamp: _now(),
    ));
    notifyListeners();
  }

  // ── Users ───────────────────────────────────────────────────
  UserModel? userById(String id) =>
      users.cast<UserModel?>().firstWhere((u) => u?.id == id, orElse: () => null);

  UserModel? userByEmail(String email) =>
      users.cast<UserModel?>().firstWhere(
          (u) => u?.email.toLowerCase() == email.toLowerCase(),
          orElse: () => null);

  void addUser(UserModel user, String actor, String actorRole) {
    users.add(user);
    _log(actor, actorRole, user.company ?? '',
        'User ${user.name} (${user.role}) registered', 'User');
    notifyListeners();
  }

  void updateUserStatus(String email, String newStatus,
      String actor, String actorRole) {
    final u = userByEmail(email);
    if (u == null) return;
    final old = u.status;
    u.status = newStatus;
    u.lastUpdatedBy = actor; u.lastUpdatedAt = _now();
    _log(actor, actorRole, u.company ?? '',
        'User ${u.name}: $old → $newStatus', 'User');
    notifyListeners();
  }

  void updateUserProfile(String id, {
    String? name, String? phone, String? address,
    String? driverLicense, String? dateOfBirth,
    String actor = 'User', String actorRole = 'Client',
  }) {
    final u = userById(id);
    if (u == null) return;
    if (name != null) u.name = name;
    if (phone != null) u.phone = phone;
    if (address != null) u.address = address;
    if (driverLicense != null) u.driverLicense = driverLicense;
    if (dateOfBirth != null) u.dateOfBirth = dateOfBirth;
    u.lastUpdatedBy = actor; u.lastUpdatedAt = _now();
    _log(actor, actorRole, '', 'User ${u.name} profile updated', 'User');
    notifyListeners();
  }

  // ── Companies ───────────────────────────────────────────────
  SharedCompany? companyById(String id) =>
      companies.cast<SharedCompany?>().firstWhere(
          (c) => c?.id == id, orElse: () => null);

  SharedCompany? companyByName(String name) =>
      companies.cast<SharedCompany?>().firstWhere(
          (c) => c?.name.toLowerCase() == name.toLowerCase(),
          orElse: () => null);

  void addCompany(SharedCompany company, String actor, String actorRole) {
    companies.add(company);
    _log(actor, actorRole, company.name,
        'Company ${company.name} registered (${company.rentalModel}, '
        '${company.commissionPct.toInt()}% commission)', 'Company');
    notifyListeners();
  }

  void updateCompanyStatus(String id, String newStatus,
      String actor, String actorRole) {
    final c = companyById(id) ?? companyByName(id);
    if (c == null) return;
    final old = c.status;
    c.status = newStatus;
    c.lastUpdatedBy = actor; c.lastUpdatedAt = _now();
    if (newStatus == 'Active' && c.approvedAt.isEmpty) {
      c.approvedAt = _now();
    }
    _log(actor, actorRole, c.name,
        'Company ${c.name}: $old → $newStatus', 'Company');
    notifyListeners();
  }

  // ── Cars ────────────────────────────────────────────────────
  SharedCar? carById(String id) =>
      cars.cast<SharedCar?>().firstWhere((c) => c?.id == id, orElse: () => null);

  List<SharedCar> carsForCompany(String companyName) =>
      cars.where((c) => c.company.toLowerCase() == companyName.toLowerCase()).toList();

  List<Map<String, dynamic>> carsForCompanyAsMaps(String companyName) =>
      carsForCompany(companyName).map((c) => c.toMap()).toList();

  void addCar(SharedCar car, String actor, String actorRole) {
    cars.add(car);
    _log(actor, actorRole, car.company,
        '${car.name} added to ${car.company} fleet', 'Fleet');
    notifyListeners();
  }

  void updateCar(SharedCar updated, String actor, String actorRole) {
    final idx = cars.indexWhere((c) => c.id == updated.id);
    if (idx >= 0) {
      updated.lastUpdatedBy = actor; updated.lastUpdatedAt = _now();
      cars[idx] = updated;
    }
    _log(actor, actorRole, updated.company,
        '${updated.name} details updated', 'Fleet');
    notifyListeners();
  }

  void removeCar(String carId, String actor, String actorRole) {
    final c = carById(carId);
    if (c == null) return;
    cars.removeWhere((car) => car.id == carId);
    _log(actor, actorRole, c.company, '${c.name} removed from fleet', 'Fleet');
    notifyListeners();
  }

  void toggleCarAvailability(String carId, String actor, String actorRole) {
    final c = carById(carId);
    if (c == null) return;
    c.available = !c.available;
    c.lastUpdatedBy = actor; c.lastUpdatedAt = _now();
    _log(actor, actorRole, c.company,
        '${c.name} → ${c.available ? "Available" : "Rented Out"}', 'Fleet');
    notifyListeners();
  }

  // ── Bookings ────────────────────────────────────────────────
  SharedBooking? bookingById(String id) =>
      bookings.cast<SharedBooking?>().firstWhere(
          (b) => b?.id == id || b?.ref == id, orElse: () => null);

  List<SharedBooking> bookingsForCompany(String companyName) =>
      bookings.where((b) =>
          b.companyName.toLowerCase() == companyName.toLowerCase()).toList();

  List<SharedBooking> bookingsForUser(String userId) =>
      bookings.where((b) => b.customerId == userId).toList();

  /// Create a booking and trigger payment recording on company wallet
  void addBooking(SharedBooking booking, String actor, String actorRole) {
    booking.createdAt = _now();
    bookings.add(booking);

    // Push notification to company
    _pushNotification(
      title: 'New Booking',
      body: '${booking.customerName} booked ${booking.carName}',
      type: 'booking', targetRole: 'companyAdmin',
    );

    // Track user activity
    addUserActivity(UserActivity(
      id: 'UA${userActivity.length + 1}',
      userId: booking.customerId,
      title: 'Booked ${booking.carName}',
      subtitle: '${booking.companyName} · ${booking.pickupDate} → ${booking.returnDate} · \$${booking.total.toInt()}',
      icon: '🚗',
      category: 'Booking',
    ));

    _log(actor, actorRole, booking.companyName,
        'Booking ${booking.ref} created: ${booking.customerName} – '
        '${booking.carName} (${booking.pickupDate} → ${booking.returnDate})', 'Booking');
    notifyListeners();
  }

  void updateBookingStatus(String ref, String newStatus,
      String actor, String actorRole) {
    final b = bookingById(ref);
    if (b == null) return;
    final old = b.status;
    b.status = newStatus;
    b.lastUpdatedBy = actor; b.lastUpdatedAt = _now();

    _pushNotification(
      title: 'Booking $ref Updated',
      body: 'Status changed: $old → $newStatus',
      type: 'booking', targetRole: 'user',
    );

    _log(actor, actorRole, b.companyName,
        'Booking ${b.ref}: $old → $newStatus (${b.carName} / ${b.customerName})', 'Booking');
    notifyListeners();
  }

  // ── Reviews ─────────────────────────────────────────────────
  List<SharedReview> reviewsForCompany(String companyName) =>
      reviews.where((r) =>
          r.companyName.toLowerCase() == companyName.toLowerCase()).toList();

  void addReview(SharedReview review, String actor, String actorRole) {
    reviews.add(review);
    // Update company average rating
    final compReviews = reviewsForCompany(review.companyName);
    final avg = compReviews.fold(0, (s, r) => s + r.rating) / compReviews.length;
    final c = companyByName(review.companyName);
    if (c != null) c.rating = double.parse(avg.toStringAsFixed(1));

    _log(actor, actorRole, review.companyName,
        '${review.customerName} posted ${review.rating}★ review for ${review.carName}', 'Review');
    notifyListeners();
  }

  void replyToReview(String reviewId, String reply, String actor, String actorRole) {
    final r = reviews.cast<SharedReview?>().firstWhere(
        (r) => r?.id == reviewId, orElse: () => null);
    if (r == null) return;
    r.reply = reply; r.replyAt = _now();
    _log(actor, actorRole, r.companyName,
        'Reply added to review by ${r.customerName}', 'Review');
    notifyListeners();
  }

  // ── Team members ────────────────────────────────────────────
  List<TeamMember> teamForCompany(String companyName) =>
      teamMembers.where((t) =>
          t.companyName.toLowerCase() == companyName.toLowerCase()).toList();

  void addTeamMember(TeamMember member, String actor, String actorRole) {
    teamMembers.add(member);
    _log(actor, actorRole, member.companyName,
        '${member.name} (${member.role}) added to ${member.companyName} team', 'Team');
    notifyListeners();
  }

  void removeTeamMember(String memberId, String actor, String actorRole) {
    final m = teamMembers.cast<TeamMember?>().firstWhere(
        (t) => t?.id == memberId, orElse: () => null);
    if (m == null) return;
    teamMembers.removeWhere((t) => t.id == memberId);
    _log(actor, actorRole, m.companyName,
        '${m.name} removed from ${m.companyName} team', 'Team');
    notifyListeners();
  }

  void toggleTeamMemberStatus(String memberId, String actor, String actorRole) {
    final m = teamMembers.cast<TeamMember?>().firstWhere(
        (t) => t?.id == memberId, orElse: () => null);
    if (m == null) return;
    m.isActive = !m.isActive;
    _log(actor, actorRole, m.companyName,
        '${m.name} → ${m.isActive ? "Active" : "Inactive"}', 'Team');
    notifyListeners();
  }

  // ── Notifications ───────────────────────────────────────────
  List<AppNotification> notificationsForRole(String role) =>
      notifications.where((n) => n.targetRole == role).toList();

  int unreadCount(String role) =>
      notificationsForRole(role).where((n) => !n.isRead).length;

  void markAllRead(String role) {
    for (final n in notificationsForRole(role)) { n.isRead = true; }
    notifyListeners();
  }

  void _pushNotification({
    required String title, required String body,
    required String type, required String targetRole,
  }) {
    notifications.insert(0, AppNotification(
      id: 'NTF${notifications.length + 1}',
      title: title, body: body, type: type,
      targetUserId: '', targetRole: targetRole,
      createdAt: _now(),
    ));
  }

  // ── Settings change log ────────────────────────────────────
  void logSettingsChange(String detail, String actor,
      String actorRole, String company) {
    _log(actor, actorRole, company, detail, 'Settings');
  }

  // ── Helpers ─────────────────────────────────────────────────
  String _now() {
    final t = DateTime.now();
    return '${_p(t.day)}/${_p(t.month)}/${t.year} ${_p(t.hour)}:${_p(t.minute)}';
  }
  String _p(int n) => n.toString().padLeft(2, '0');

  String _uid() => DateTime.now().millisecondsSinceEpoch.toString();

  // ═══════════════════════════════════════════════════════════
  //  SEED DATA
  //  Replace with API calls in production.
  // ═══════════════════════════════════════════════════════════
  void _seed() {

    // ── Users ──────────────────────────────────────────────────
    users.addAll([
      UserModel(id:'U001', name:'Cameron One',    email:'C1@gmail.com',       phone:'+250 788 000 001', role:'Client',        status:'Active',    trips:12, spent:1240.0, memberSince:'Jan 2024', driverLicense:'RW-DL-2021-004521', isVerified:true),
      UserModel(id:'U002', name:'Alice Mugisha',  email:'alice@email.com',    phone:'+250 788 111 222', role:'Client',        status:'Active',    trips:8,  spent:890.0,  memberSince:'Mar 2024', driverLicense:'RW-DL-2022-001187', isVerified:true),
      UserModel(id:'U003', name:'Bob Nkusi',      email:'bob@email.com',      phone:'+250 788 333 444', role:'Client',        status:'Suspended', trips:2,  spent:120.0,  memberSince:'Jun 2024', driverLicense:'RW-DL-2023-009932', isVerified:false),
      UserModel(id:'U004', name:'Diana Uwase',    email:'diana@email.com',    phone:'+250 788 555 666', role:'Company Admin', status:'Active',    company:'DriveKigali',  trips:21, spent:3200.0, memberSince:'Nov 2023', isVerified:true),
      UserModel(id:'U005', name:'Eric Habimana',  email:'eric@email.com',     phone:'+250 788 777 888', role:'Company Staff', status:'Inactive',  company:'SafariWheels', trips:0,  spent:0.0,    memberSince:'Sep 2024'),
      UserModel(id:'U006', name:'Fiona Ingabire', email:'fiona@email.com',    phone:'+250 788 999 000', role:'Client',        status:'Active',    trips:5,  spent:670.0,  memberSince:'Feb 2024', driverLicense:'RW-DL-2022-007743', isVerified:true),
      UserModel(id:'U007', name:'James Doe',      email:'staffmember',        phone:'+250 788 201 001', role:'Company Staff', status:'Active',    company:'DriveKigali',  trips:0,  spent:0.0,    memberSince:'Jan 2024', isVerified:true),
      UserModel(id:'U008', name:'Super Admin',    email:'admin@swiftride.rw', phone:'+250 788 000 000', role:'Super Admin',   status:'Active',    trips:0,  spent:0.0,    memberSince:'Jan 2023', isVerified:true),
    ]);

    // ── Companies ───────────────────────────────────────────────
    companies.addAll([
      SharedCompany(id:'C001', name:'DriveKigali',  status:'Active',    location:'KG 7 Ave, Kigali',       adminName:'Diana Uwase',   adminEmail:'diana@email.com',    phone:'+250 788 100 001', regNumber:'RW-BIZ-2019-001', email:'info@drivekigali.rw',   website:'www.drivekigali.rw',   rentalModel:'Daily',     commissionPct:10.0, agents:4, cars:28, bookings:156, revenue:18200, rating:4.9, categories:['SUV','Sedan','Economy'], documentsVerified:true,  approvedAt:'01/01/2019 09:00'),
      SharedCompany(id:'C002', name:'SafariWheels', status:'Active',    location:'KN 3 Rd, Remera',        adminName:'James Doe',     adminEmail:'james@safari.rw',    phone:'+250 788 200 002', regNumber:'RW-BIZ-2020-042', email:'info@safariwheels.rw',  website:'www.safariwheels.rw',  rentalModel:'Hybrid',    commissionPct:12.0, agents:3, cars:12, bookings:89,  revenue:11400, rating:4.8, categories:['SUV','Luxury'],         documentsVerified:true,  approvedAt:'15/03/2020 10:00'),
      SharedCompany(id:'C003', name:'LuxDrive',     status:'Active',    location:'KG 11 Ave, Nyarutarama', adminName:'Mary Uwimana',  adminEmail:'mary@luxdrive.rw',   phone:'+250 788 300 003', regNumber:'RW-BIZ-2021-017', email:'info@luxdrive.rw',      website:'www.luxdrive.rw',      rentalModel:'Monthly',   commissionPct:8.0,  agents:6, cars:8,  bookings:44,  revenue:9800,  rating:4.7, categories:['Luxury','SUV'],         documentsVerified:true,  approvedAt:'20/06/2021 08:00'),
      SharedCompany(id:'C004', name:'RwandaRide',   status:'Pending',   location:'KN 5 Rd, Nyamirambo',   adminName:'Paul Ndoli',    adminEmail:'paul@rwandaride.rw', phone:'+250 788 400 004', regNumber:'RW-BIZ-2024-088', email:'info@rwandaride.rw',    website:'',                     rentalModel:'Long-Term', commissionPct:15.0, agents:2, cars:5,  bookings:21,  revenue:2400,  rating:4.5, categories:['Economy','Van'],        documentsVerified:false),
      SharedCompany(id:'C005', name:'VanGo',        status:'Suspended', location:'KG 9 Ave, Gisozi',       adminName:'Kevin Ishimwe', adminEmail:'kevin@vango.rw',     phone:'+250 788 500 005', regNumber:'RW-BIZ-2022-033', email:'info@vango.rw',         website:'www.vango.rw',         rentalModel:'Daily',     commissionPct:10.0, agents:1, cars:6,  bookings:12,  revenue:1100,  rating:3.9, categories:['Van'],                  documentsVerified:true,  approvedAt:'10/04/2022 11:00'),
    ]);

    // ── Cars ────────────────────────────────────────────────────
    cars.addAll([
      SharedCar(id:'CAR001', name:'Toyota RAV4',      brand:'Toyota',     category:'SUV',     price:60,  seats:5, transmission:'Automatic', fuel:'Petrol', company:'DriveKigali',  year:'2022', color:0xFF1B5E20, rating:4.7, description:'Reliable compact SUV, perfect for Kigali city and Rwanda\'s varied terrain.', available:true),
      SharedCar(id:'CAR002', name:'Hyundai Tucson',   brand:'Hyundai',    category:'SUV',     price:55,  seats:5, transmission:'Automatic', fuel:'Petrol', company:'DriveKigali',  year:'2021', color:0xFF37474F, rating:4.5, description:'Comfortable and fuel-efficient SUV with modern features.', available:false),
      SharedCar(id:'CAR003', name:'Toyota Camry',     brand:'Toyota',     category:'Sedan',   price:45,  seats:5, transmission:'Automatic', fuel:'Petrol', company:'DriveKigali',  year:'2021', color:0xFF1A237E, rating:4.6, description:'Dependable mid-size sedan with low running costs and smooth ride.', available:true),
      SharedCar(id:'CAR004', name:'Volkswagen Golf',  brand:'Volkswagen', category:'Economy', price:38,  seats:5, transmission:'Manual',    fuel:'Petrol', company:'DriveKigali',  year:'2020', color:0xFF4E342E, rating:4.3, description:'Affordable and practical hatchback, great for city driving.', available:true),
      SharedCar(id:'CAR005', name:'BMW 5 Series',     brand:'BMW',        category:'Luxury',  price:90,  seats:5, transmission:'Automatic', fuel:'Petrol', company:'SafariWheels', year:'2022', color:0xFF880E4F, rating:4.8, description:'Executive luxury sedan combining performance with comfort.', available:true),
      SharedCar(id:'CAR006', name:'Range Rover',      brand:'Land Rover', category:'SUV',     price:120, seats:7, transmission:'Automatic', fuel:'Diesel', company:'LuxDrive',     year:'2023', color:0xFF1B5E20, rating:4.7, description:'Premium 4x4 with luxury interior. Perfect for both city and off-road.', available:false),
      SharedCar(id:'CAR007', name:'Mercedes GLE',     brand:'Mercedes',   category:'SUV',     price:100, seats:7, transmission:'Automatic', fuel:'Diesel', company:'LuxDrive',     year:'2022', color:0xFF263238, rating:4.8, description:'Spacious luxury SUV with advanced driver assistance systems.', available:true),
      SharedCar(id:'CAR008', name:'Honda CR-V',       brand:'Honda',      category:'SUV',     price:65,  seats:5, transmission:'Automatic', fuel:'Petrol', company:'RwandaRide',   year:'2021', color:0xFF37474F, rating:4.5, description:'Versatile and practical SUV with excellent fuel economy.', available:true),
      SharedCar(id:'CAR009', name:'Tesla Model S',    brand:'Tesla',      category:'Electric',price:120, seats:5, transmission:'Automatic', fuel:'Electric', company:'SafariWheels', year:'2023', color:0xFF1A237E, rating:4.9, description:'All-electric luxury sedan with autopilot and 405mi range.', available:true),
      SharedCar(id:'CAR010', name:'Porsche 911',      brand:'Porsche',    category:'Sports',  price:200, seats:2, transmission:'Manual',    fuel:'Petrol', company:'LuxDrive',     year:'2023', color:0xFF4E342E, rating:5.0, description:'Iconic sports car with exceptional handling on Rwanda\'s scenic roads.', available:true),
    ]);

    // ── Bookings ────────────────────────────────────────────────
    bookings.addAll([
      SharedBooking(id:'B001', ref:'SW240001', customerId:'U001', customerName:'Cameron One',    customerPhone:'+250 788 000 001', carId:'CAR001', carName:'Toyota RAV4',    carBrand:'Toyota',  carCategory:'SUV',    carColor:0xFF1B5E20, carSeats:5, carFuel:'Petrol', carTransmission:'Automatic', carYear:'2022', companyId:'C001', companyName:'DriveKigali',  pickupDate:'May 24, 2026', returnDate:'May 27, 2026', pickupLocation:'Kigali City Centre', dropoffLocation:'Kigali City Centre', days:3, pricePerDay:60, subtotal:180, serviceFee:18, insurance:15,  total:213, paymentMethod:'Credit Card',      paymentReference:'**** 4521', status:'Active',    createdAt:'24/05/2026 09:00'),
      SharedBooking(id:'B002', ref:'SW240002', customerId:'U004', customerName:'Diana Uwase',    customerPhone:'+250 788 555 666', carId:'CAR005', carName:'BMW 5 Series',   carBrand:'BMW',     carCategory:'Luxury', carColor:0xFF880E4F, carSeats:5, carFuel:'Petrol', carTransmission:'Automatic', carYear:'2022', companyId:'C002', companyName:'SafariWheels', pickupDate:'Jun 1, 2026',  returnDate:'Jun 3, 2026',  pickupLocation:'Kigali International Airport', dropoffLocation:'Nyamirambo', days:2, pricePerDay:90, subtotal:180, serviceFee:18, insurance:30,  total:228, paymentMethod:'MTN Mobile Money', paymentReference:'+250 788 555 666', status:'Upcoming',  createdAt:'01/06/2026 08:00'),
      SharedBooking(id:'B003', ref:'SW240003', customerId:'U002', customerName:'Alice Mugisha',  customerPhone:'+250 788 111 222', carId:'CAR006', carName:'Range Rover',    carBrand:'Land Rover', carCategory:'SUV', carColor:0xFF1B5E20, carSeats:7, carFuel:'Diesel', carTransmission:'Automatic', carYear:'2023', companyId:'C003', companyName:'LuxDrive',     pickupDate:'Apr 10, 2026', returnDate:'Apr 12, 2026', pickupLocation:'Kimironko Market', dropoffLocation:'Gisozi', days:2, pricePerDay:120, subtotal:240, serviceFee:24, insurance:30, total:294, paymentMethod:'Credit Card',      paymentReference:'**** 1187', status:'Completed', createdAt:'10/04/2026 07:30'),
      SharedBooking(id:'B004', ref:'SW240004', customerId:'U003', customerName:'Bob Nkusi',      customerPhone:'+250 788 333 444', carId:'CAR003', carName:'Toyota Camry',   carBrand:'Toyota',  carCategory:'Sedan', carColor:0xFF1A237E, carSeats:5, carFuel:'Petrol', carTransmission:'Automatic', carYear:'2021', companyId:'C001', companyName:'DriveKigali',  pickupDate:'Mar 5, 2026',  returnDate:'Mar 7, 2026',  pickupLocation:'Kigali International Airport', dropoffLocation:'Kigali City Centre', days:2, pricePerDay:45, subtotal:90, serviceFee:9, insurance:30, total:129, paymentMethod:'Cash on Pickup', paymentReference:'', status:'Cancelled', createdAt:'05/03/2026 10:00'),
      SharedBooking(id:'B005', ref:'SW240005', customerId:'U006', customerName:'Fiona Ingabire', customerPhone:'+250 788 999 000', carId:'CAR007', carName:'Mercedes GLE',   carBrand:'Mercedes',carCategory:'SUV',   carColor:0xFF263238, carSeats:7, carFuel:'Diesel', carTransmission:'Automatic', carYear:'2022', companyId:'C003', companyName:'LuxDrive',     pickupDate:'Jun 8, 2026',  returnDate:'Jun 10, 2026', pickupLocation:'Nyarutarama', dropoffLocation:'Kimironko Market', days:2, pricePerDay:100, subtotal:200, serviceFee:20, insurance:30, total:250, paymentMethod:'Airtel Money', paymentReference:'+250 733 999 000', status:'Active',    createdAt:'08/06/2026 11:00'),
      SharedBooking(id:'B006', ref:'SW240006', customerId:'U005', customerName:'Eric Habimana',  customerPhone:'+250 788 777 888', carId:'CAR008', carName:'Honda CR-V',     carBrand:'Honda',   carCategory:'SUV',   carColor:0xFF37474F, carSeats:5, carFuel:'Petrol', carTransmission:'Automatic', carYear:'2021', companyId:'C004', companyName:'RwandaRide',   pickupDate:'May 1, 2026',  returnDate:'May 3, 2026',  pickupLocation:'Remera', dropoffLocation:'Kicukiro', days:2, pricePerDay:65, subtotal:130, serviceFee:13, insurance:30, total:173, paymentMethod:'MTN Mobile Money', paymentReference:'+250 788 777 888', status:'Completed', createdAt:'01/05/2026 09:30'),
    ]);

    // ── Reviews ─────────────────────────────────────────────────
    reviews.addAll([
      SharedReview(id:'R001', bookingRef:'SW240001', customerId:'U001', customerName:'Cameron One',    companyId:'C001', companyName:'DriveKigali',  carId:'CAR001', carName:'Toyota RAV4',  rating:5, comment:'Excellent service! Car was spotless and pickup was smooth. Will book again.', createdAt:'27/05/2026 14:00'),
      SharedReview(id:'R002', bookingRef:'SW240003', customerId:'U002', customerName:'Alice Mugisha',  companyId:'C003', companyName:'LuxDrive',      carId:'CAR006', carName:'Range Rover',  rating:4, comment:'Great experience overall. Car in perfect condition. Highly recommend.', createdAt:'12/04/2026 10:00'),
      SharedReview(id:'R003', bookingRef:'SW240005', customerId:'U006', customerName:'Fiona Ingabire', companyId:'C003', companyName:'LuxDrive',      carId:'CAR007', carName:'Mercedes GLE', rating:5, comment:'Perfect for our trip. The Mercedes handled everything beautifully.', createdAt:'10/06/2026 16:00'),
    ]);

    // ── Team members ────────────────────────────────────────────
    teamMembers.addAll([
      TeamMember(id:'TM001', name:'James Doe',    email:'james@drivekigali.rw', phone:'+250 788 201 001', role:'Senior Agent',  companyId:'C001', companyName:'DriveKigali',  isActive:true,  joinedAt:'15/01/2024 08:00'),
      TeamMember(id:'TM002', name:'Mary Uwimana', email:'mary@drivekigali.rw',  phone:'+250 788 201 002', role:'Fleet Manager', companyId:'C001', companyName:'DriveKigali',  isActive:true,  joinedAt:'01/02/2024 09:00'),
      TeamMember(id:'TM003', name:'Paul Ndoli',   email:'paul@drivekigali.rw',  phone:'+250 788 201 003', role:'Agent',         companyId:'C001', companyName:'DriveKigali',  isActive:false, joinedAt:'10/03/2024 10:00'),
      TeamMember(id:'TM004', name:'Eric Habimana',email:'eric@safariwheels.rw', phone:'+250 788 777 888', role:'Agent',         companyId:'C002', companyName:'SafariWheels', isActive:false, joinedAt:'05/09/2024 08:00'),
    ]);

    // ── Seed audit history ──────────────────────────────────────
    _seedAudit();
  }

  void _seedAudit() {
    final now = DateTime.now();
    void e(String actor, String role, String company,
        String action, String cat, int minutesAgo) {
      final t = now.subtract(Duration(minutes: minutesAgo));
      auditLog.add(AuditEntry(
        id: 'AL${auditLog.length + 1}', actor: actor, actorRole: role,
        company: company, action: action, category: cat,
        timestamp: '${_p(t.day)}/${_p(t.month)}/${t.year} ${_p(t.hour)}:${_p(t.minute)}',
      ));
    }
    e('System','System','DriveKigali','Company DriveKigali approved & activated','Company',525600);
    e('System','System','SafariWheels','Company SafariWheels approved & activated','Company',438000);
    e('System','System','LuxDrive','Company LuxDrive approved & activated','Company',350400);
    e('System','System','RwandaRide','RwandaRide registration submitted — pending approval','Company',2880);
    e('DriveKigali Admin','Company Admin','DriveKigali','Toyota RAV4 (CAR001) added to fleet','Fleet',10080);
    e('DriveKigali Admin','Company Admin','DriveKigali','Hyundai Tucson (CAR002) added to fleet','Fleet',8640);
    e('DriveKigali Admin','Company Admin','DriveKigali','Booking SW240001 created: Cameron One – Toyota RAV4','Booking',4320);
    e('DriveKigali Admin','Company Admin','DriveKigali','Booking SW240001: Upcoming → Active','Booking',2160);
    e('DriveKigali Admin','Company Admin','DriveKigali','James Doe added as Senior Agent','Team',1440);
    e('DriveKigali Admin','Company Admin','DriveKigali','Hyundai Tucson → Rented Out','Fleet',720);
    e('SafariWheels Admin','Company Admin','SafariWheels','BMW 5 Series (CAR005) added to fleet','Fleet',7200);
    e('SafariWheels Admin','Company Admin','SafariWheels','Booking SW240002 created: Diana Uwase – BMW 5 Series','Booking',2880);
    e('LuxDrive Admin','Company Admin','LuxDrive','Range Rover (CAR006) added to fleet','Fleet',5040);
    e('LuxDrive Admin','Company Admin','LuxDrive','Booking SW240003: Active → Completed (Alice Mugisha)','Booking',1440);
    e('Cameron One','Client','DriveKigali','5★ review posted for Toyota RAV4','Review',1200);
    e('Super Admin','Super Admin','','Bob Nkusi account suspended (ToS violation)','User',4320);
    e('Super Admin','Super Admin','RwandaRide','RwandaRide documents under review','Company',2880);
    e('Super Admin','Super Admin','','Platform analytics reviewed — Q2 2026','Settings',180);
    e('System','System','','Audit log initialized — permanent record active','Settings',0);
  }
}
