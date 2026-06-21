// lib/services/cars_service.dart
import 'package:swiftride/services/api_service.dart';

class CarModel {
  final String  id, name, brand, category, transmission, fuelType, status, companyId, companyName;
  final int     seats, pricePerDay, year;
  final double  avgRating;
  final String? primaryImage;

  const CarModel({
    required this.id, required this.name, required this.brand,
    required this.category, required this.transmission, required this.fuelType,
    required this.status, required this.companyId, required this.companyName,
    required this.seats, required this.pricePerDay, required this.year,
    required this.avgRating, this.primaryImage,
  });

  factory CarModel.fromJson(Map<String, dynamic> j) => CarModel(
    id:           j['id']?.toString()                   ?? '',
    name:         j['name']?.toString()                 ?? '',
    brand:        j['brand']?.toString()                ?? '',
    category:     j['category']?.toString()             ?? 'Economy',
    transmission: j['transmission']?.toString()         ?? 'Auto',
    fuelType:     j['fuel_type']?.toString()            ?? 'Petrol',
    status:       j['status']?.toString()               ?? 'available',
    companyId:    j['company']?.toString()              ?? '',
    companyName:  j['company_detail']?['name']?.toString() ?? '',
    seats:        (j['seats']   as num?)?.toInt()       ?? 5,
    pricePerDay:  (j['price_per_day'] as num?)?.toInt() ?? 0,
    year:         (j['year']    as num?)?.toInt()       ?? 2023,
    avgRating:    (j['avg_rating'] as num?)?.toDouble() ?? 0.0,
    primaryImage: j['primary_image']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'brand': brand, 'category': category,
    'transmission': transmission, 'fuel': fuelType, 'status': status,
    'company': companyId, 'seats': seats, 'price': pricePerDay,
    'year': year, 'rating': avgRating, 'image': primaryImage,
  };
}

class CarsService {
  CarsService._();
  static final CarsService instance = CarsService._();
  final _api = ApiService.instance;

  Future<List<CarModel>> getCars({
    String? category, int? minPrice, int? maxPrice,
    int? minSeats, String? search, String? ordering,
  }) async {
    final params = <String, String>{};
    if (category != null)  params['category']  = category;
    if (minPrice != null)  params['min_price']  = '$minPrice';
    if (maxPrice != null)  params['max_price']  = '$maxPrice';
    if (minSeats != null)  params['min_seats']  = '$minSeats';
    if (search   != null)  params['search']     = search;
    if (ordering != null)  params['ordering']   = ordering;

    final data = await _api.get('/cars/', params: params);
    final results = (data is Map ? data['results'] : data) as List? ?? [];
    return results.map((j) => CarModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getCarDetail(String id) async {
    return await _api.get('/cars/$id/') as Map<String, dynamic>;
  }

  Future<List<CarModel>> getFleet() async {
    final data = await _api.get('/cars/fleet/');
    final results = (data is Map ? data['results'] : data) as List? ?? [];
    return results.map((j) => CarModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> addCar(Map<String, dynamic> carData) async {
    return await _api.post('/cars/fleet/', body: carData) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCar(String id, Map<String, dynamic> carData) async {
    return await _api.patch('/cars/fleet/$id/', body: carData) as Map<String, dynamic>;
  }

  Future<void> deleteCar(String id) async {
    await _api.delete('/cars/fleet/$id/');
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final data = await _api.get('/cars/favorites/');
    final results = (data is Map ? data['results'] : data) as List? ?? [];
    return results.cast<Map<String, dynamic>>();
  }

  Future<bool> toggleFavorite(String carId) async {
    final data = await _api.post('/cars/$carId/favorite/');
    return data['favorited'] as bool? ?? false;
  }
}
