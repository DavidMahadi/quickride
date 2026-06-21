from django.urls import path
from . import views

urlpatterns = [
    path('',                          views.CarListView.as_view(),           name='car-list'),
    path('<uuid:pk>/',                views.CarDetailView.as_view(),         name='car-detail'),
    path('fleet/',                    views.CompanyCarListView.as_view(),    name='fleet-list'),
    path('fleet/<uuid:pk>/',          views.CompanyCarDetailView.as_view(),  name='fleet-detail'),
    path('fleet/<uuid:car_pk>/images/', views.CarImageUploadView.as_view(), name='car-images'),
    path('favorites/',                views.FavoriteListView.as_view(),      name='favorites'),
    path('<uuid:car_pk>/favorite/',   views.FavoriteToggleView.as_view(),    name='favorite-toggle'),
]
