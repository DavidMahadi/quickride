# apps/cars/views.py
from rest_framework import generics, status, permissions, filters
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiExample
from drf_spectacular.types import OpenApiTypes
from swiftride.apps.companies.permissions import IsCompanyAdmin, IsCompanyStaff
from swiftride.apps.audit.utils import log_action
from .models import Car, CarImage, CarFeature, FavoriteCar
from .serializers import CarSerializer, CarMiniSerializer, CarImageSerializer, FavoriteCarSerializer
from .filters import CarFilter


@extend_schema(
    tags=['Cars'],
    summary='List all available cars',
    description='Public endpoint. Filter by category, price, seats, transmission, fuel type, and company.',
    parameters=[
        OpenApiParameter('category',     OpenApiTypes.STR,   description='Economy | SUV | Sedan | Luxury | Sports | Van | Electric | 4x4'),
        OpenApiParameter('min_price',    OpenApiTypes.NUMBER, description='Minimum price per day (USD)'),
        OpenApiParameter('max_price',    OpenApiTypes.NUMBER, description='Maximum price per day (USD)'),
        OpenApiParameter('min_seats',    OpenApiTypes.INT,   description='Minimum number of seats'),
        OpenApiParameter('transmission', OpenApiTypes.STR,   description='Auto | Manual'),
        OpenApiParameter('fuel_type',    OpenApiTypes.STR,   description='Petrol | Diesel | Electric | Hybrid'),
        OpenApiParameter('has_ac',       OpenApiTypes.BOOL,  description='Filter by air conditioning'),
        OpenApiParameter('has_gps',      OpenApiTypes.BOOL,  description='Filter by GPS'),
        OpenApiParameter('search',       OpenApiTypes.STR,   description='Search by name, brand or company'),
        OpenApiParameter('ordering',     OpenApiTypes.STR,   description='Sort: price_per_day | avg_rating | -created_at'),
    ]
)
class CarListView(generics.ListAPIView):
    serializer_class   = CarMiniSerializer
    permission_classes = [permissions.AllowAny]
    queryset           = Car.objects.filter(status='available').select_related('company').prefetch_related('images')
    filter_backends    = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class    = CarFilter
    search_fields      = ['name', 'brand', 'model', 'company__name']
    ordering_fields    = ['price_per_day', 'avg_rating', 'created_at']


@extend_schema(tags=['Cars'], summary='Get full car details including images, features and reviews')
class CarDetailView(generics.RetrieveAPIView):
    serializer_class   = CarSerializer
    permission_classes = [permissions.AllowAny]
    queryset           = Car.objects.all().select_related('company').prefetch_related('images', 'features')


@extend_schema(
    tags=['Fleet'],
    summary='List company fleet / add a new car',
    description='Company staff and admins can view their fleet and add new cars.',
    examples=[
        OpenApiExample('Add car', value={
            'name': 'Toyota RAV4 2023', 'brand': 'Toyota', 'model': 'RAV4', 'year': 2023,
            'plate_number': 'RAC 001 A', 'category': 'SUV', 'transmission': 'Auto',
            'fuel_type': 'Petrol', 'seats': 5, 'price_per_day': 60, 'deposit_amount': 100
        }, request_only=True)
    ]
)
class CompanyCarListView(generics.ListCreateAPIView):
    permission_classes = [IsCompanyStaff]

    def get_serializer_class(self):
        return CarSerializer if self.request.method == 'POST' else CarMiniSerializer

    def get_queryset(self):
        return Car.objects.filter(company=self.request.user.company)

    def perform_create(self, serializer):
        car     = serializer.save(company=self.request.user.company)
        company = self.request.user.company
        company.total_cars     = company.cars.count()
        company.available_cars = company.cars.filter(status='available').count()
        company.save(update_fields=['total_cars', 'available_cars'])
        log_action(self.request.user, 'create', 'Car', str(car.id), f'Car {car.name} added to fleet')


@extend_schema(tags=['Fleet'], summary='Get, update or remove a car from the fleet')
class CompanyCarDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class   = CarSerializer
    permission_classes = [IsCompanyStaff]

    def get_queryset(self):
        return Car.objects.filter(company=self.request.user.company)

    def perform_destroy(self, instance):
        log_action(self.request.user, 'delete', 'Car', str(instance.id), f'{instance.name} removed')
        instance.delete()


@extend_schema(tags=['Fleet'], summary='Upload an image for a car')
class CarImageUploadView(generics.CreateAPIView):
    serializer_class   = CarImageSerializer
    permission_classes = [IsCompanyStaff]

    def perform_create(self, serializer):
        car = Car.objects.get(pk=self.kwargs['car_pk'], company=self.request.user.company)
        serializer.save(car=car)


@extend_schema(tags=['Favorites'], summary='List my favorite cars')
class FavoriteListView(generics.ListAPIView):
    serializer_class = FavoriteCarSerializer

    def get_queryset(self):
        return FavoriteCar.objects.filter(user=self.request.user).select_related('car')


@extend_schema(
    tags=['Favorites'],
    summary='Toggle favorite on a car',
    description='If the car is already favorited it will be removed, otherwise added. Returns `favorited: true/false`.'
)
class FavoriteToggleView(generics.GenericAPIView):
    def post(self, request, car_pk):
        car = Car.objects.get(pk=car_pk)
        fav, created = FavoriteCar.objects.get_or_create(user=request.user, car=car)
        if not created:
            fav.delete()
            return Response({'favorited': False})
        return Response({'favorited': True}, status=status.HTTP_201_CREATED)
