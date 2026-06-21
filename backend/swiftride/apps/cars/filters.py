import django_filters
from .models import Car

class CarFilter(django_filters.FilterSet):
    min_price = django_filters.NumberFilter(field_name='price_per_day', lookup_expr='gte')
    max_price = django_filters.NumberFilter(field_name='price_per_day', lookup_expr='lte')
    min_seats = django_filters.NumberFilter(field_name='seats', lookup_expr='gte')

    class Meta:
        model  = Car
        fields = ['category', 'transmission', 'fuel_type', 'company', 'status',
                  'min_price', 'max_price', 'min_seats', 'has_ac', 'has_gps']
