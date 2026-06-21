from django.urls import path
from . import views

urlpatterns = [
    path('',                views.CreateBookingView.as_view(),      name='booking-create'),
    path('mine/',           views.MyBookingsView.as_view(),         name='my-bookings'),
    path('<uuid:pk>/',      views.BookingDetailView.as_view(),      name='booking-detail'),
    path('<uuid:pk>/cancel/', views.CancelBookingView.as_view(),    name='booking-cancel'),
    path('company/',        views.CompanyBookingListView.as_view(), name='company-bookings'),
    path('company/<uuid:pk>/status/', views.UpdateBookingStatusView.as_view(), name='booking-status'),
    path('admin/',          views.AdminBookingListView.as_view(),   name='admin-bookings'),
]
