from rest_framework import serializers
from decimal import Decimal
from .models import Wallet, WalletTransaction


class WalletSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Wallet
        fields = ('id', 'balance', 'currency', 'is_active', 'updated_at')
        read_only_fields = fields


class WalletTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model  = WalletTransaction
        fields = ('id', 'tx_type', 'amount', 'balance_before', 'balance_after',
                  'status', 'reference', 'description', 'booking', 'created_at')
        read_only_fields = fields


class TransferSerializer(serializers.Serializer):
    to_wallet   = serializers.UUIDField()
    amount      = serializers.DecimalField(max_digits=10, decimal_places=2, min_value=Decimal('0.01'))
    description = serializers.CharField(required=False, default='')


class WithdrawSerializer(serializers.Serializer):
    amount      = serializers.DecimalField(max_digits=10, decimal_places=2, min_value=Decimal('0.01'))
    destination = serializers.CharField(max_length=100)
    description = serializers.CharField(required=False, default='')
