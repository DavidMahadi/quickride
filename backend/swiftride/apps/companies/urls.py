from django.urls import path
from . import views

urlpatterns = [
    path('',               views.CompanyListView.as_view(),     name='company-list'),
    path('register/',      views.CompanyCreateView.as_view(),   name='company-register'),
    path('my/',            views.MyCompanyView.as_view(),       name='my-company'),
    path('my/documents/',  views.CompanyDocumentView.as_view(), name='company-documents'),
    path('<uuid:pk>/',     views.CompanyDetailView.as_view(),   name='company-detail'),
    path('<uuid:pk>/approve/', views.CompanyApproveView.as_view(),  name='company-approve'),
    path('<uuid:pk>/suspend/', views.CompanySuspendView.as_view(),  name='company-suspend'),
]
