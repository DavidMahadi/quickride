from django.urls import path
from . import views

urlpatterns = [
    path('',                         views.CreateReviewView.as_view(),   name='review-create'),
    path('car/<uuid:car_pk>/',       views.CarReviewsView.as_view(),     name='car-reviews'),
    path('company/<uuid:company_pk>/',views.CompanyReviewsView.as_view(),name='company-reviews'),
    path('<uuid:pk>/reply/',         views.ReplyReviewView.as_view(),    name='review-reply'),
]
