# apps/notifications/models.py
import uuid
from django.db import models


class Notification(models.Model):
    class Type(models.TextChoices):
        BOOKING_CONFIRMED  = 'booking_confirmed',  'Booking Confirmed'
        BOOKING_CANCELLED  = 'booking_cancelled',  'Booking Cancelled'
        BOOKING_REMINDER   = 'booking_reminder',   'Booking Reminder'
        PAYMENT_RECEIVED   = 'payment_received',   'Payment Received'
        CAR_AVAILABLE      = 'car_available',      'Car Available'
        REVIEW_RECEIVED    = 'review_received',    'Review Received'
        COMPANY_APPROVED   = 'company_approved',   'Company Approved'
        COMPANY_SUSPENDED  = 'company_suspended',  'Company Suspended'
        WALLET_CREDIT      = 'wallet_credit',      'Wallet Credit'
        WALLET_DEBIT       = 'wallet_debit',       'Wallet Debit'
        SYSTEM             = 'system',             'System'

    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user       = models.ForeignKey(
        'users.User', on_delete=models.CASCADE, related_name='notifications'
    )
    type       = models.CharField(max_length=30, choices=Type.choices)
    title      = models.CharField(max_length=150)
    body       = models.TextField()
    data       = models.JSONField(default=dict, blank=True)   # extra payload
    is_read    = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
        indexes  = [models.Index(fields=['user', 'is_read'])]

    def __str__(self):
        return f'{self.type} → {self.user.full_name}'
