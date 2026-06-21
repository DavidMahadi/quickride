from rest_framework import serializers
from .models import Company, CompanyDocument
from swiftride.apps.users.serializers import UserMiniSerializer


class CompanySerializer(serializers.ModelSerializer):
    class Meta:
        model  = Company
        fields = '__all__'
        read_only_fields = ('id', 'slug', 'avg_rating', 'total_bookings',
                            'total_revenue', 'total_cars', 'available_cars',
                            'created_at', 'updated_at', 'approved_at', 'approved_by')

    def create(self, validated_data):
        from django.utils.text import slugify
        validated_data['slug'] = slugify(validated_data['name'])
        return super().create(validated_data)


class CompanyMiniSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Company
        fields = ('id', 'name', 'slug', 'logo', 'location', 'avg_rating',
                  'total_cars', 'available_cars', 'status', 'rental_model')


class CompanyDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model  = CompanyDocument
        fields = ('id', 'doc_type', 'file', 'is_verified', 'uploaded_at')
        read_only_fields = ('id', 'is_verified', 'uploaded_at')
