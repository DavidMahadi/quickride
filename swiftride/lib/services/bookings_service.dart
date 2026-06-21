// lib/services/bookings_service.dart
import 'package:swiftride/services/api_service.dart';

class BookingModel {
  final String id, ref, status, paymentStatus, paymentMethod;
  final String pickupDate, returnDate, pickupLocation, dropoffLocation;
  final String carName, companyName, carId, companyId;
  final double total;
  final int    days;
  final String createdAt;

  const BookingModel({
    required this.id, required this.ref, required this.status,
    required this.paymentStatus, required this.paymentMethod,
    required this.pickupDate, required this.returnDate,
    required this.pickupLocation, required this.dropoffLocation,
    required this.carName, required this.companyName,
    required this.carId, required this.companyId,
    required this.total, required this.days, required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) => BookingModel(
    id:              j['id']?.toString()                          ?? '',
    ref:             j['ref']?.toString()                         ?? '',
    status:          j['status']?.toString()                      ?? 'pending',
    paymentStatus:   j['payment_status']?.toString()              ?? 'unpaid',
    paymentMethod:   j['payment_method']?.toString()              ?? 'cash',
    pickupDate:      j['pickup_date']?.toString()                 ?? '',
    returnDate:      j['return_date']?.toString()                 ?? '',
    pickupLocation:  j['pickup_location']?.toString()             ?? '',
    dropoffLocation: j['dropoff_location']?.toString()            ?? '',
    carName:         j['car_detail']?['name']?.toString()         ?? '',
    companyName:     j['company_detail']?['name']?.toString()     ?? '',
    carId:           j['car']?.toString()                         ?? '',
    companyId:       j['company']?.toString()                     ?? '',
    total:           (j['total'] as num?)?.toDouble()             ?? 0.0,
    days:            (j['days']  as num?)?.toInt()                ?? 1,
    createdAt:       j['created_at']?.toString()                  ?? '',
  );
}

class BookingsService {
  BookingsService._();
  static final BookingsService instance = BookingsService._();
  final _api = ApiService.instance;

  Future<List<BookingModel>> getMyBookings({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    final data    = await _api.get('/bookings/mine/', params: params);
    final results = (data is Map ? data['results'] : data) as List? ?? [];
    return results.map((j) => BookingModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<BookingModel> getBookingDetail(String id) async {
    final data = await _api.get('/bookings/$id/');
    return BookingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<BookingModel> createBooking({
    required String carId,
    required String pickupDate,
    required String returnDate,
    required String pickupLocation,
    required String dropoffLocation,
    required String paymentMethod,
    String notes = '',
  }) async {
    final data = await _api.post('/bookings/', body: {
      'car':              carId,
      'pickup_date':      pickupDate,
      'return_date':      returnDate,
      'pickup_location':  pickupLocation,
      'dropoff_location': dropoffLocation,
      'payment_method':   paymentMethod,
      'notes':            notes,
    });
    return BookingModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> cancelBooking(String id, {String reason = ''}) async {
    await _api.post('/bookings/$id/cancel/', body: {'reason': reason});
  }

  // Company staff
  Future<List<BookingModel>> getCompanyBookings({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    final data    = await _api.get('/bookings/company/', params: params);
    final results = (data is Map ? data['results'] : data) as List? ?? [];
    return results.map((j) => BookingModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> updateBookingStatus(String id, String status, {String note = ''}) async {
    await _api.post('/bookings/company/$id/status/', body: {
      'status': status, 'note': note,
    });
  }
}
