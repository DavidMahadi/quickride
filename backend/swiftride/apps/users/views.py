# apps/users/views.py
from rest_framework import generics, status, permissions
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenRefreshView
from django.contrib.auth import get_user_model
from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiExample, OpenApiResponse
from swiftride.apps.audit.utils import log_action
from .models import UserDocument, SavedAddress
from .serializers import (
    RegisterSerializer, LoginSerializer, UserSerializer,
    ChangePasswordSerializer, UserDocumentSerializer, SavedAddressSerializer,
)

User = get_user_model()


def get_tokens(user):
    refresh = RefreshToken.for_user(user)
    return {'refresh': str(refresh), 'access': str(refresh.access_token)}


@extend_schema(
    tags=['Auth'],
    summary='Register a new customer account',
    description='Creates a new customer account and returns JWT tokens immediately.',
    examples=[
        OpenApiExample('Example request', value={
            'email': 'david@example.com', 'full_name': 'David Mugisha',
            'phone': '+250 788 000 001', 'password': 'secret123', 'password2': 'secret123'
        }, request_only=True),
        OpenApiExample('Example response', value={
            'access': '<jwt_access_token>', 'refresh': '<jwt_refresh_token>',
            'user': {'id': 'uuid', 'email': 'david@example.com', 'full_name': 'David Mugisha', 'role': 'customer'}
        }, response_only=True),
    ]
)
class RegisterView(generics.CreateAPIView):
    serializer_class   = RegisterSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user   = serializer.save()
        tokens = get_tokens(user)
        log_action(user, 'create', 'User', str(user.id), 'User registered')
        return Response({**tokens, 'user': UserSerializer(user).data}, status=status.HTTP_201_CREATED)


@extend_schema(
    tags=['Auth'],
    summary='Login and get JWT tokens',
    description='Authenticate with email and password. Returns access + refresh tokens and user profile.',
    examples=[
        OpenApiExample('Customer login', value={'email': 'c1@gmail.com', 'password': '123123'}, request_only=True),
        OpenApiExample('Staff login', value={'email': 'staff@company.com', 'password': 'staff123'}, request_only=True),
        OpenApiExample('Company admin login', value={'email': 'admin@company.com', 'password': 'admin123'}, request_only=True),
        OpenApiExample('Super admin login', value={'email': 'super@swiftride.com', 'password': 'super123'}, request_only=True),
    ]
)
class LoginView(generics.GenericAPIView):
    serializer_class   = LoginSerializer
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user   = serializer.validated_data['user']
        tokens = get_tokens(user)
        log_action(user, 'login', 'User', str(user.id), 'User logged in',
                   ip=request.META.get('REMOTE_ADDR'), ua=request.META.get('HTTP_USER_AGENT', ''))
        return Response({**tokens, 'user': UserSerializer(user).data})


@extend_schema(
    tags=['Auth'],
    summary='Logout — blacklist refresh token',
    description='Invalidates the provided refresh token. Pass the refresh token in the request body.',
    examples=[OpenApiExample('Example', value={'refresh': '<refresh_token>'}, request_only=True)]
)
class LogoutView(generics.GenericAPIView):
    def post(self, request):
        try:
            token = RefreshToken(request.data['refresh'])
            token.blacklist()
            log_action(request.user, 'logout', 'User', str(request.user.id), 'User logged out')
        except Exception:
            pass
        return Response(status=status.HTTP_204_NO_CONTENT)


@extend_schema(tags=['Profile'], summary='Get or update own profile')
class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user


@extend_schema(tags=['Profile'], summary='Change own password')
class ChangePasswordView(generics.GenericAPIView):
    serializer_class = ChangePasswordSerializer

    def post(self, request):
        serializer = self.get_serializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'detail': 'Password changed successfully.'})


@extend_schema(tags=['Profile'], summary='List / upload KYC documents')
class UserDocumentView(generics.ListCreateAPIView):
    serializer_class = UserDocumentSerializer

    def get_queryset(self):
        return UserDocument.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


@extend_schema(tags=['Profile'], summary='List / add saved addresses')
class SavedAddressView(generics.ListCreateAPIView):
    serializer_class = SavedAddressSerializer

    def get_queryset(self):
        return SavedAddress.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


@extend_schema(tags=['Profile'], summary='Get, update or delete a saved address')
class SavedAddressDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = SavedAddressSerializer

    def get_queryset(self):
        return SavedAddress.objects.filter(user=self.request.user)


@extend_schema(tags=['Admin'], summary='List all users (super admin only)')
class UserListView(generics.ListAPIView):
    serializer_class   = UserSerializer
    permission_classes = [permissions.IsAdminUser]
    queryset           = User.objects.all()
    search_fields      = ['full_name', 'email', 'phone']
    filterset_fields   = ['role', 'is_active', 'is_verified']


@extend_schema(tags=['Admin'], summary='Get / update a specific user (super admin only)')
class UserDetailAdminView(generics.RetrieveUpdateAPIView):
    serializer_class   = UserSerializer
    permission_classes = [permissions.IsAdminUser]
    queryset           = User.objects.all()
