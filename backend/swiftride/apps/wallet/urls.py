from django.urls import path
from . import views

urlpatterns = [
    path('',            views.MyWalletView.as_view(),            name='my-wallet'),
    path('transactions/',views.WalletTransactionListView.as_view(),name='wallet-transactions'),
    path('transfer/',   views.TransferView.as_view(),             name='wallet-transfer'),
    path('withdraw/',   views.WithdrawView.as_view(),             name='wallet-withdraw'),
]
