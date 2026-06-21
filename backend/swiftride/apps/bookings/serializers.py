from rest_framework import serializers
from .models import Booking, BookingStatusLog
from swiftride.apps.users.serializers import UserMiniSerializer
from swiftride.apps.cars.serializers import CarMiniSerializer
from swiftride.apps.companies.serializers import CompanyMiniSerializer


class BookingStatusLogSerializer(serializers.ModelSerializer):
    changed_by = UserMiniSerializer(read_only=True)
    class Meta:
        model  = BookingStatusLog
        fields = ('id', 'from_status', 'to_status', 'changed_by', 'note', 'changed_at')


class BookingSerializer(serializers.ModelSerializer):
    customer_detail = UserMiniSerializer(source='customer', read_only=True)
    car_detail      = CarMiniSerializer(source='car',      read_only=True)
    company_detail  = CompanyMiniSerializer(source='company', read_only=True)
    status_logs     = BookingStatusLogSerializer(many=True, read_only=True)

    class Meta:
        model  = Booking
        fields = '__all__'
        read_only_fields = (
            'id', 'ref', 'company', 'subtotal', 'total',
            'created_at', 'updated_at', 'cancelled_at'
        )

    def validate(self, data):
        if data.get('pickup_date') and data.get('return_date'):
            if data['pickup_date'] >= data['return_date']:
                raise serializers.ValidationError('Return date must be after pickup date.')
        return data


class CreateBookingSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Booking
        fields = (
            'car', 'pickup_date', 'return_date',
            'pickup_location', 'dropoff_location', 'payment_method', 'notes',
        )

    def validate_car(self, car):
        if not car.is_available:
            raise serializers.ValidationError('This car is not available.')
        return car

    def validate(self, data):
        if data['pickup_date'] >= data['return_date']:
            raise serializers.ValidationError('Return date must be after pickup date.')
        return data

    def create(self, validated_data):
        from django.db import transaction
        car     = validated_data['car']
        days    = (validated_data['return_date'] - validated_data['pickup_date']).days or 1
        subtotal = car.price_per_day * days
        total    = subtotal + car.deposit_amount

        with transaction.atomic():
            booking = Booking.objects.create(
                customer        = self.context['request'].user,
                company         = car.company,
                days            = days,
                price_per_day   = car.price_per_day,
                subtotal        = subtotal,
                deposit         = car.deposit_amount,
                total           = total,
                **validated_data
            )
            # Mark car as rented
            car.status = 'rented'
            car.save(update_fields=['status'])

            # Log status
            BookingStatusLog.objects.create(
                booking    = booking,
                to_status  = booking.status,
                changed_by = self.context['request'].user,
                note       = 'Booking created',
            )
        return booking


class BookingMiniSerializer(serializers.ModelSerializer):
    car_detail     = CarMiniSerializer(source='car', read_only=True)
    company_detail = CompanyMiniSerializer(source='company', read_only=True)

    class Meta:
        model  = Booking
        fields = ('id', 'ref', 'status', 'payment_status', 'pickup_date',
                  'return_date', 'total', 'car_detail', 'company_detail', 'created_at')
