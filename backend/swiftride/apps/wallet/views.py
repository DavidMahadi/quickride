from drf_spectacular.utils import extend_schema
from rest_framework import generics, status
from rest_framework.response import Response
from django.db import transaction as db_transaction
from swiftride.apps.audit.utils import log_action
from .models import Wallet, WalletTransaction
from .serializers import WalletSerializer, WalletTransactionSerializer, TransferSerializer, WithdrawSerializer


def get_or_create_wallet(user):
    wallet, _ = Wallet.objects.get_or_create(user=user, defaults={'currency': 'USD'})
    return wallet


@extend_schema(tags=['Wallet'])
class MyWalletView(generics.RetrieveAPIView):
    serializer_class = WalletSerializer

    def get_object(self):
        return get_or_create_wallet(self.request.user)


@extend_schema(tags=['Wallet'])
class WalletTransactionListView(generics.ListAPIView):
    serializer_class = WalletTransactionSerializer

    def get_queryset(self):
        wallet = get_or_create_wallet(self.request.user)
        return WalletTransaction.objects.filter(wallet=wallet)


@extend_schema(tags=['Wallet'])
class TransferView(generics.GenericAPIView):
    serializer_class = TransferSerializer

    def post(self, request):
        s = self.get_serializer(data=request.data)
        s.is_valid(raise_exception=True)
        from_wallet = get_or_create_wallet(request.user)
        to_wallet   = Wallet.objects.get(pk=s.validated_data['to_wallet'])
        amount      = s.validated_data['amount']

        with db_transaction.atomic():
            from_wallet.debit(amount, save=False)
            to_wallet.credit(amount, save=False)

            WalletTransaction.objects.create(
                wallet=from_wallet, tx_type='transfer', amount=amount,
                balance_before=from_wallet.balance + amount,
                balance_after=from_wallet.balance,
                description=s.validated_data.get('description', ''),
                created_by=request.user,
            )
            WalletTransaction.objects.create(
                wallet=to_wallet, tx_type='credit', amount=amount,
                balance_before=to_wallet.balance - amount,
                balance_after=to_wallet.balance,
                description=f'Transfer from {request.user.full_name}',
                created_by=request.user,
            )
            from_wallet.save()
            to_wallet.save()

        log_action(request.user, 'update', 'Wallet', str(from_wallet.id),
                   f'Transferred ${amount} to wallet {to_wallet.id}')
        return Response({'detail': f'Transferred ${amount} successfully.'})


@extend_schema(tags=['Wallet'])
class WithdrawView(generics.GenericAPIView):
    serializer_class = WithdrawSerializer

    def post(self, request):
        s = self.get_serializer(data=request.data)
        s.is_valid(raise_exception=True)
        wallet = get_or_create_wallet(request.user)
        amount = s.validated_data['amount']

        with db_transaction.atomic():
            wallet.debit(amount)
            WalletTransaction.objects.create(
                wallet=wallet, tx_type='withdrawal', amount=amount,
                balance_before=wallet.balance + amount,
                balance_after=wallet.balance,
                description=s.validated_data.get('description', ''),
                reference=s.validated_data['destination'],
                created_by=request.user,
            )

        return Response({'detail': f'Withdrawal of ${amount} initiated.'})

from drf_spectacular.utils import extend_schema

MyWalletView             = extend_schema(tags=['Wallet'], summary='Get my wallet balance')(MyWalletView)
WalletTransactionListView= extend_schema(tags=['Wallet'], summary='List my wallet transactions')(WalletTransactionListView)
TransferView             = extend_schema(tags=['Wallet'], summary='Transfer funds to another wallet')(TransferView)
WithdrawView             = extend_schema(tags=['Wallet'], summary='Withdraw funds from wallet')(WithdrawView)
