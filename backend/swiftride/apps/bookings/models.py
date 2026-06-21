# apps/bookings/models.py
import uuid
from django.db import models
from django.utils import timezone


def generate_ref():
    import random, string
    return 'SR' + ''.join(random.choices(string.digits, k=7))


class Booking(models.Model):
    class Status(models.TextChoices):
        PENDING   = 'pending',   'Pending'
        CONFIRMED = 'confirmed', 'Confirmed'
        ACTIVE    = 'active',    'Active'
        COMPLETED = 'completed', 'Completed'
        CANCELLED = 'cancelled', 'Cancelled'

    class PaymentStatus(models.TextChoices):
        UNPAID    = 'unpaid',    'Unpaid'
        PARTIAL   = 'partial',   'Partial'
        PAID      = 'paid',      'Paid'
        REFUNDED  = 'refunded',  'Refunded'

    class PaymentMethod(models.TextChoices):
        CASH          = 'cash',           'Cash'
        MOBILE_MTN    = 'mobile_mtn',     'MTN Mobile Money'
        MOBILE_AIRTEL = 'mobile_airtel',  'Airtel Money'
        CARD          = 'card',           'Card'
        WALLET        = 'wallet',         'SwiftRide Wallet'

    id              = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    ref             = models.CharField(max_length=12, unique=True, default=generate_ref)

    # Parties
    customer        = models.ForeignKey(
        'users.User', on_delete=models.PROTECT, related_name='bookings'
    )
    car             = models.ForeignKey(
        'cars.Car', on_delete=models.PROTECT, related_name='bookings'
    )
    company         = models.ForeignKey(
        'companies.Company', on_delete=models.PROTECT, related_name='bookings'
    )
    handled_by      = models.ForeignKey(
        'users.User', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='handled_bookings'
    )

    # Dates
    pickup_date     = models.DateTimeField()
    return_date     = models.DateTimeField()
    actual_return   = models.DateTimeField(null=True, blank=True)

    # Locations
    pickup_location  = models.TextField()
    dropoff_location = models.TextField()

    # Pricing snapshot (stored at booking time)
    days             = models.PositiveSmallIntegerField()
    price_per_day    = models.DecimalField(max_digits=8, decimal_places=2)
    subtotal         = models.DecimalField(max_digits=10, decimal_places=2)
    deposit          = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    discount         = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    total            = models.DecimalField(max_digits=10, decimal_places=2)
    currency         = models.CharField(max_length=3, default='USD')

    # Payment
    payment_method   = models.CharField(max_length=20, choices=PaymentMethod.choices, default=PaymentMethod.CASH)
    payment_status   = models.CharField(max_length=10, choices=PaymentStatus.choices, default=PaymentStatus.UNPAID)
    amount_paid      = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    # Status
    status           = models.CharField(max_length=15, choices=Status.choices, default=Status.PENDING)
    notes            = models.TextField(blank=True)
    cancellation_reason = models.TextField(blank=True)
    cancelled_at     = models.DateTimeField(null=True, blank=True)

    created_at       = models.DateTimeField(auto_now_add=True)
    updated_at       = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'bookings'
        ordering = ['-created_at']
        indexes  = [
            models.Index(fields=['customer', 'status']),
            models.Index(fields=['company',  'status']),
            models.Index(fields=['car',      'status']),
            models.Index(fields=['pickup_date', 'return_date']),
        ]

    def __str__(self):
        return f'{self.ref} — {self.customer.full_name} → {self.car}'

    @property
    def duration_days(self):
        delta = self.return_date - self.pickup_date
        return max(delta.days, 1)

    def cancel(self, reason=''):
        self.status = self.Status.CANCELLED
        self.cancellation_reason = reason
        self.cancelled_at = timezone.now()
        self.save(update_fields=['status', 'cancellation_reason', 'cancelled_at', 'updated_at'])


class BookingStatusLog(models.Model):
    """Immutable history of every status change on a booking."""
    id          = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    booking     = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name='status_logs')
    from_status = models.CharField(max_length=15, blank=True)
    to_status   = models.CharField(max_length=15)
    changed_by  = models.ForeignKey(
        'users.User', null=True, on_delete=models.SET_NULL, related_name='booking_changes'
    )
    note        = models.TextField(blank=True)
    changed_at  = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'booking_status_logs'
        ordering = ['changed_at']
