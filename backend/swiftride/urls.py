# swiftride/urls.py
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.views.generic import RedirectView
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
    SpectacularRedocView,
)

urlpatterns = [
    # Redirect root to docs
    path('', RedirectView.as_view(url='/api/docs/', permanent=False)),

    path('admin/', admin.site.urls),

    # Swagger / OpenAPI
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/',   SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/',  SpectacularRedocView.as_view(url_name='schema'),   name='redoc'),

    # App routes
    path('api/auth/',          include('swiftride.apps.users.urls')),
    path('api/companies/',     include('swiftride.apps.companies.urls')),
    path('api/cars/',          include('swiftride.apps.cars.urls')),
    path('api/bookings/',      include('swiftride.apps.bookings.urls')),
    path('api/reviews/',       include('swiftride.apps.reviews.urls')),
    path('api/notifications/', include('swiftride.apps.notifications.urls')),
    path('api/chat/',          include('swiftride.apps.chat.urls')),
    path('api/wallet/',        include('swiftride.apps.wallet.urls')),
    path('api/audit/',         include('swiftride.apps.audit.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
