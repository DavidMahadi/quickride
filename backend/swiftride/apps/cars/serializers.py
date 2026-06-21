from rest_framework import serializers
from .models import Car, CarImage, CarFeature, FavoriteCar
from swiftride.apps.companies.serializers import CompanyMiniSerializer


class CarImageSerializer(serializers.ModelSerializer):
    class Meta:
        model  = CarImage
        fields = ('id', 'image', 'is_primary', 'order')


class CarFeatureSerializer(serializers.ModelSerializer):
    class Meta:
        model  = CarFeature
        fields = ('id', 'label')


class CarSerializer(serializers.ModelSerializer):
    images   = CarImageSerializer(many=True, read_only=True)
    features = CarFeatureSerializer(many=True, read_only=True)
    company_detail = CompanyMiniSerializer(source='company', read_only=True)
    is_favorited   = serializers.SerializerMethodField()

    class Meta:
        model  = Car
        fields = '__all__'
        read_only_fields = ('id', 'avg_rating', 'total_trips', 'created_at', 'updated_at')

    def get_is_favorited(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return FavoriteCar.objects.filter(user=request.user, car=obj).exists()
        return False


class CarMiniSerializer(serializers.ModelSerializer):
    primary_image = serializers.SerializerMethodField()
    class Meta:
        model  = Car
        fields = ('id', 'name', 'brand', 'model', 'year', 'category',
                  'price_per_day', 'seats', 'transmission', 'fuel_type',
                  'status', 'avg_rating', 'primary_image', 'company')

    def get_primary_image(self, obj):
        img = obj.images.filter(is_primary=True).first() or obj.images.first()
        if img:
            request = self.context.get('request')
            return request.build_absolute_uri(img.image.url) if request else img.image.url
        return None


class FavoriteCarSerializer(serializers.ModelSerializer):
    car = CarMiniSerializer(read_only=True)
    class Meta:
        model  = FavoriteCar
        fields = ('id', 'car', 'created_at')
