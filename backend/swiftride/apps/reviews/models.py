# apps/reviews/models.py
import uuid
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models


class Review(models.Model):
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    booking    = models.OneToOneField(
        'bookings.Booking', on_delete=models.CASCADE, related_name='review'
    )
    customer   = models.ForeignKey(
        'users.User', on_delete=models.CASCADE, related_name='reviews_given'
    )
    car        = models.ForeignKey(
        'cars.Car', on_delete=models.CASCADE, related_name='reviews'
    )
    company    = models.ForeignKey(
        'companies.Company', on_delete=models.CASCADE, related_name='reviews'
    )

    # Ratings
    overall_rating    = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    cleanliness_rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)], null=True, blank=True
    )
    value_rating      = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)], null=True, blank=True
    )
    service_rating    = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)], null=True, blank=True
    )

    comment    = models.TextField(blank=True)
    is_public  = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    # Company reply
    reply      = models.TextField(blank=True)
    replied_at = models.DateTimeField(null=True, blank=True)
    replied_by = models.ForeignKey(
        'users.User', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='review_replies'
    )

    class Meta:
        db_table = 'reviews'
        ordering = ['-created_at']

    def __str__(self):
        return f'Review by {self.customer.full_name} for {self.car} — {self.overall_rating}★'
