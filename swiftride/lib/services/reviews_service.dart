// lib/services/reviews_service.dart
import 'package:swiftride/services/api_service.dart';

class ReviewModel {
  final String id, bookingId, customerName, comment, createdAt;
  final int    overallRating;
  final String? reply;

  const ReviewModel({
    required this.id, required this.bookingId, required this.customerName,
    required this.comment, required this.createdAt, required this.overallRating,
    this.reply,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
    id:            j['id']?.toString()                              ?? '',
    bookingId:     j['booking']?.toString()                         ?? '',
    customerName:  j['customer_detail']?['full_name']?.toString()   ?? '',
    comment:       j['comment']?.toString()                         ?? '',
    createdAt:     j['created_at']?.toString()                      ?? '',
    overallRating: (j['overall_rating'] as num?)?.toInt()           ?? 0,
    reply:         j['reply']?.toString(),
  );
}

class ReviewsService {
  ReviewsService._();
  static final ReviewsService instance = ReviewsService._();
  final _api = ApiService.instance;

  Future<List<ReviewModel>> getCarReviews(String carId) async {
    final data    = await _api.get('/reviews/car/$carId/');
    final results = (data is Map ? data['results'] : data) as List? ?? [];
    return results.map((j) => ReviewModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<ReviewModel> submitReview({
    required String bookingId,
    required int    rating,
    String comment = '',
  }) async {
    final data = await _api.post('/reviews/', body: {
      'booking':        bookingId,
      'overall_rating': rating,
      'comment':        comment,
    });
    return ReviewModel.fromJson(data as Map<String, dynamic>);
  }
}
