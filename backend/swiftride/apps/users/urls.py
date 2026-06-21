from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path('register/',         views.RegisterView.as_view(),        name='register'),
    path('login/',            views.LoginView.as_view(),           name='login'),
    path('logout/',           views.LogoutView.as_view(),          name='logout'),
    path('token/refresh/',    TokenRefreshView.as_view(),          name='token-refresh'),
    path('profile/',          views.ProfileView.as_view(),         name='profile'),
    path('change-password/',  views.ChangePasswordView.as_view(),  name='change-password'),
    path('documents/',        views.UserDocumentView.as_view(),    name='documents'),
    path('addresses/',        views.SavedAddressView.as_view(),    name='addresses'),
    path('addresses/<uuid:pk>/', views.SavedAddressDetailView.as_view(), name='address-detail'),
    # Admin
    path('admin/users/',         views.UserListView.as_view(),        name='admin-users'),
    path('admin/users/<uuid:pk>/',views.UserDetailAdminView.as_view(), name='admin-user-detail'),
]
