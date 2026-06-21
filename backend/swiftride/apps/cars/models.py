# apps/cars/models.py
import uuid
from django.db import models


class Car(models.Model):
    class Category(models.TextChoices):
        ECONOMY  = 'Economy',  'Economy'
        SUV      = 'SUV',      'SUV'
        SEDAN    = 'Sedan',    'Sedan'
        LUXURY   = 'Luxury',   'Luxury'
        SPORTS   = 'Sports',   'Sports'
        VAN      = 'Van',      'Van'
        TRUCK    = 'Truck',    'Truck'
        ELECTRIC = 'Electric', 'Electric'
        FOUR_X_FOUR = '4x4',  '4x4'

    class Transmission(models.TextChoices):
        AUTO   = 'Auto',   'Automatic'
        MANUAL = 'Manual', 'Manual'

    class FuelType(models.TextChoices):
        PETROL   = 'Petrol',   'Petrol'
        DIESEL   = 'Diesel',   'Diesel'
        ELECTRIC = 'Electric', 'Electric'
        HYBRID   = 'Hybrid',   'Hybrid'

    class Status(models.TextChoices):
        AVAILABLE  = 'available',  'Available'
        RENTED     = 'rented',     'Rented'
        MAINTENANCE= 'maintenance','Under Maintenance'
        INACTIVE   = 'inactive',   'Inactive'

    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company      = models.ForeignKey(
        'companies.Company', on_delete=models.CASCADE, related_name='cars'
    )

    # Identity
    name         = models.CharField(max_length=100)
    brand        = models.CharField(max_length=50)
    model        = models.CharField(max_length=50)
    year         = models.PositiveSmallIntegerField()
    plate_number = models.CharField(max_length=20, unique=True)
    vin          = models.CharField(max_length=17, blank=True)
    color        = models.CharField(max_length=30, blank=True)

    # Specs
    category     = models.CharField(max_length=20, choices=Category.choices, default=Category.ECONOMY)
    transmission = models.CharField(max_length=10, choices=Transmission.choices, default=Transmission.AUTO)
    fuel_type    = models.CharField(max_length=10, choices=FuelType.choices, default=FuelType.PETROL)
    seats        = models.PositiveSmallIntegerField(default=5)
    doors        = models.PositiveSmallIntegerField(default=4)
    mileage      = models.PositiveIntegerField(default=0)    # km
    engine_cc    = models.PositiveIntegerField(null=True, blank=True)
    has_ac       = models.BooleanField(default=True)
    has_gps      = models.BooleanField(default=False)
    has_bluetooth= models.BooleanField(default=False)
    has_usb      = models.BooleanField(default=False)

    # Pricing
    price_per_day   = models.DecimalField(max_digits=8, decimal_places=2)
    price_per_month = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    deposit_amount  = models.DecimalField(max_digits=8, decimal_places=2, default=0)

    # Status & stats
    status       = models.CharField(max_length=15, choices=Status.choices, default=Status.AVAILABLE)
    avg_rating   = models.DecimalField(max_digits=3, decimal_places=2, default=0.00)
    total_trips  = models.PositiveIntegerField(default=0)
    description  = models.TextField(blank=True)

    created_at   = models.DateTimeField(auto_now_add=True)
    updated_at   = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'cars'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.year} {self.brand} {self.model} — {self.company.name}'

    @property
    def is_available(self):
        return self.status == self.Status.AVAILABLE


class CarImage(models.Model):
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    car        = models.ForeignKey(Car, on_delete=models.CASCADE, related_name='images')
    image      = models.ImageField(upload_to='car_images/')
    is_primary = models.BooleanField(default=False)
    order      = models.PositiveSmallIntegerField(default=0)
    uploaded_at= models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'car_images'
        ordering = ['order']

    def save(self, *args, **kwargs):
        # Only one primary image per car
        if self.is_primary:
            CarImage.objects.filter(car=self.car, is_primary=True).update(is_primary=False)
        super().save(*args, **kwargs)


class CarFeature(models.Model):
    """Extra features / tags for a car (e.g. Baby Seat, Roof Rack)."""
    id    = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    car   = models.ForeignKey(Car, on_delete=models.CASCADE, related_name='features')
    label = models.CharField(max_length=50)

    class Meta:
        db_table = 'car_features'
        unique_together = ('car', 'label')

    def __str__(self):
        return f'{self.car} — {self.label}'


class FavoriteCar(models.Model):
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user       = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='favorites')
    car        = models.ForeignKey(Car, on_delete=models.CASCADE, related_name='favorited_by')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table        = 'favorite_cars'
        unique_together = ('user', 'car')

    def __str__(self):
        return f'{self.user.full_name} ♥ {self.car}'
