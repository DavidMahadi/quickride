# apps/wallet/models.py
import uuid
from django.db import models


class Wallet(models.Model):
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    # Either owned by a user OR a company (not both)
    user       = models.OneToOneField(
        'users.User', null=True, blank=True,
        on_delete=models.CASCADE, related_name='wallet'
    )
    company    = models.OneToOneField(
        'companies.Company', null=True, blank=True,
        on_delete=models.CASCADE, related_name='wallet'
    )
    balance    = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    currency   = models.CharField(max_length=3, default='USD')
    is_active  = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'wallets'

    def __str__(self):
        owner = self.user or self.company
        return f'Wallet({owner}) ${self.balance}'

    def credit(self, amount, save=True):
        self.balance += amount
        if save: self.save(update_fields=['balance', 'updated_at'])

    def debit(self, amount, save=True):
        if self.balance < amount:
            raise ValueError('Insufficient wallet balance')
        self.balance -= amount
        if save: self.save(update_fields=['balance', 'updated_at'])


class WalletTransaction(models.Model):
    class TxType(models.TextChoices):
        CREDIT     = 'credit',     'Credit'
        DEBIT      = 'debit',      'Debit'
        TRANSFER   = 'transfer',   'Transfer'
        WITHDRAWAL = 'withdrawal', 'Withdrawal'
        REFUND     = 'refund',     'Refund'
        COMMISSION = 'commission', 'Commission'

    class TxStatus(models.TextChoices):
        PENDING   = 'pending',   'Pending'
        COMPLETED = 'completed', 'Completed'
        FAILED    = 'failed',    'Failed'
        REVERSED  = 'reversed',  'Reversed'

    id          = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    wallet      = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name='transactions')
    tx_type     = models.CharField(max_length=15, choices=TxType.choices)
    amount      = models.DecimalField(max_digits=12, decimal_places=2)
    balance_before = models.DecimalField(max_digits=12, decimal_places=2)
    balance_after  = models.DecimalField(max_digits=12, decimal_places=2)
    status      = models.CharField(max_length=10, choices=TxStatus.choices, default=TxStatus.COMPLETED)
    reference   = models.CharField(max_length=100, blank=True)
    description = models.TextField(blank=True)
    booking     = models.ForeignKey(
        'bookings.Booking', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='wallet_transactions'
    )
    created_by  = models.ForeignKey(
        'users.User', null=True, on_delete=models.SET_NULL, related_name='wallet_transactions'
    )
    created_at  = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'wallet_transactions'
        ordering = ['-created_at']
        indexes  = [models.Index(fields=['wallet', 'tx_type', 'created_at'])]

    def __str__(self):
        return f'{self.tx_type} ${self.amount} — {self.wallet}'
