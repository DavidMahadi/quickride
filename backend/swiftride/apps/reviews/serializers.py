from rest_framework import serializers
from .models import Review
from swiftride.apps.users.serializers import UserMiniSerializer
from swiftride.apps.cars.serializers import CarMiniSerializer


class ReviewSerializer(serializers.ModelSerializer):
    customer_detail = UserMiniSerializer(source='customer', read_only=True)
    car_detail      = CarMiniSerializer(source='car',      read_only=True)

    class Meta:
        model  = Review
        fields = '__all__'
        read_only_fields = ('id', 'customer', 'car', 'company', 'created_at', 'replied_at', 'replied_by')

    def create(self, validated_data):
        from django.db import transaction
        booking = validated_data['booking']
        with transaction.atomic():
            review = Review.objects.create(
                customer = booking.customer,
                car      = booking.car,
                company  = booking.company,
                **validated_data
            )
            # Update avg ratings
            self._update_ratings(review.car, review.company)
        return review

    def _update_ratings(self, car, company):
        from django.db.models import Avg
        car_avg = car.reviews.aggregate(a=Avg('overall_rating'))['a'] or 0
        car.avg_rating = round(car_avg, 2)
        car.save(update_fields=['avg_rating'])
        co_avg = company.reviews.aggregate(a=Avg('overall_rating'))['a'] or 0
        company.avg_rating = round(co_avg, 2)
        company.save(update_fields=['avg_rating'])


class ReviewReplySerializer(serializers.Serializer):
    reply = serializers.CharField()
