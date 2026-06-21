from django.urls import path
from . import views

urlpatterns = [
    path('',    views.AuditLogListView.as_view(), name='audit-logs'),
    path('me/', views.MyAuditLogView.as_view(),   name='my-audit-logs'),
]
