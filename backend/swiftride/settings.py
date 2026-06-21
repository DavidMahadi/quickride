# swiftride/settings.py
from pathlib import Path
from datetime import timedelta
from decouple import config

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config('SECRET_KEY', default='django-insecure-dev-key-change-in-production')
DEBUG = config('DEBUG', default=True, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost,127.0.0.1').split(',')

DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

THIRD_PARTY_APPS = [
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'django_filters',
    'drf_spectacular',
    'channels',
]

LOCAL_APPS = [
    'swiftride.apps.users',
    'swiftride.apps.companies',
    'swiftride.apps.cars',
    'swiftride.apps.bookings',
    'swiftride.apps.reviews',
    'swiftride.apps.notifications',
    'swiftride.apps.chat',
    'swiftride.apps.wallet',
    'swiftride.apps.audit',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'swiftride.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'swiftride.wsgi.application'
ASGI_APPLICATION = 'swiftride.asgi.application'

# ── Database ──────────────────────────────────────────────────
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME':   BASE_DIR / 'db.sqlite3',
    }
}

# ── Cache / Channels ──────────────────────────────────────────
REDIS_URL = config('REDIS_URL', default='redis://localhost:6379/0')

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': REDIS_URL,
    }
}

CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {'hosts': [REDIS_URL]},
    }
}

# ── Auth ──────────────────────────────────────────────────────
AUTH_USER_MODEL = 'users.User'

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# ── REST Framework ────────────────────────────────────────────
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

# ── JWT ───────────────────────────────────────────────────────
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME':    timedelta(hours=24),
    'REFRESH_TOKEN_LIFETIME':   timedelta(days=30),
    'ROTATE_REFRESH_TOKENS':    True,
    'BLACKLIST_AFTER_ROTATION': True,
    'AUTH_HEADER_TYPES':        ('Bearer',),
}

# ── CORS ──────────────────────────────────────────────────────
CORS_ALLOWED_ORIGINS = [
    'http://localhost:3000',
    'http://localhost:8080',
    'http://127.0.0.1:8000',
    'http://127.0.0.1:5500',
]
CORS_ALLOW_ALL_ORIGINS   = True   # allow all during development
CORS_ALLOW_CREDENTIALS   = True
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
]
CORS_ALLOW_METHODS = [
    'DELETE', 'GET', 'OPTIONS', 'PATCH', 'POST', 'PUT',
]

# ── Swagger / OpenAPI (drf-spectacular) ───────────────────────
SPECTACULAR_SETTINGS = {
    'TITLE':       'SwiftRide API',
    'DESCRIPTION': '''
## SwiftRide — Car Rental Platform API

A complete REST API for the SwiftRide car rental platform built with Django REST Framework.

### Authentication
All protected endpoints require a **Bearer JWT token** in the `Authorization` header:
```
Authorization: Bearer <access_token>
```
Get your token from `POST /api/auth/login/`.

### User Roles
| Role | Description |
|------|-------------|
| `customer` | Browse cars, make bookings, chat, wallet |
| `company_staff` | Manage fleet, handle bookings |
| `company_admin` | Full company management |
| `super_admin` | Full platform access |

### Quick Start
1. `POST /api/auth/register/` — create account
2. `POST /api/auth/login/` — get tokens
3. `GET /api/cars/` — browse available cars
4. `POST /api/bookings/` — create a booking
''',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'CONTACT': {
        'name':  'SwiftRide Support',
        'email': 'support@swiftride.rw',
        'url':   'https://swiftride.rw',
    },
    'LICENSE': {
        'name': 'Proprietary',
    },
    'TAGS': [
        {'name': 'Auth',          'description': 'Registration, login, logout, password management'},
        {'name': 'Profile',       'description': 'User profile, documents, saved addresses'},
        {'name': 'Cars',          'description': 'Browse and filter available cars'},
        {'name': 'Fleet',         'description': 'Company fleet management (staff/admin only)'},
        {'name': 'Favorites',     'description': 'Save and manage favorite cars'},
        {'name': 'Bookings',      'description': 'Create and manage car bookings'},
        {'name': 'Company Bookings', 'description': 'Booking management for company staff'},
        {'name': 'Companies',     'description': 'Company listing and management'},
        {'name': 'Reviews',       'description': 'Car and company reviews'},
        {'name': 'Chat',          'description': 'Customer–company messaging (REST + WebSocket)'},
        {'name': 'Notifications', 'description': 'In-app notification management'},
        {'name': 'Wallet',        'description': 'Digital wallet and transactions'},
        {'name': 'Audit',         'description': 'Immutable activity log (admin only)'},
        {'name': 'Admin',         'description': 'Super admin platform management'},
    ],
    'COMPONENT_SPLIT_REQUEST': True,
    'SORT_OPERATIONS': False,
    'SWAGGER_UI_SETTINGS': {
        'deepLinking':               True,
        'persistAuthorization':      True,
        'displayOperationId':        False,
        'defaultModelsExpandDepth':  2,
        'defaultModelExpandDepth':   2,
        'docExpansion':              'list',
        'filter':                    True,
        'showExtensions':            True,
        'syntaxHighlight.activate':  True,
        'syntaxHighlight.theme':     'monokai',
    },

    'REDOC_DIST':       'SIDECAR',
}

# ── Static / Media ────────────────────────────────────────────
STATIC_URL  = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
MEDIA_URL   = '/media/'
MEDIA_ROOT  = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
LANGUAGE_CODE = 'en-us'
TIME_ZONE     = 'Africa/Kigali'
USE_I18N = True
USE_TZ   = True
