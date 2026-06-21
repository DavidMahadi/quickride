# apps/users/serializers.py
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from .models import User, UserDocument, SavedAddress


class RegisterSerializer(serializers.ModelSerializer):
    password  = serializers.CharField(write_only=True, min_length=6)
    password2 = serializers.CharField(write_only=True)

    class Meta:
        model  = User
        fields = ('email', 'full_name', 'phone', 'password', 'password2')

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError('Passwords do not match.')
        return data

    def create(self, validated_data):
        validated_data.pop('password2')
        return User.objects.create_user(**validated_data)


class LoginSerializer(serializers.Serializer):
    email    = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = authenticate(email=data['email'], password=data['password'])
        if not user:
            raise serializers.ValidationError('Invalid credentials.')
        if not user.is_active:
            raise serializers.ValidationError('Account is disabled.')
        data['user'] = user
        return data


class TokenResponseSerializer(serializers.Serializer):
    access  = serializers.CharField()
    refresh = serializers.CharField()
    user    = serializers.DictField()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model  = User
        fields = (
            'id', 'email', 'full_name', 'phone', 'role',
            'avatar', 'driver_license_no', 'driver_license_expiry',
            'date_of_birth', 'national_id', 'company', 'job_title',
            'is_verified', 'created_at',
        )
        read_only_fields = ('id', 'role', 'is_verified', 'created_at')


class UserMiniSerializer(serializers.ModelSerializer):
    class Meta:
        model  = User
        fields = ('id', 'full_name', 'email', 'phone', 'avatar', 'role')


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=6)

    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError('Old password is incorrect.')
        return value

    def save(self):
        user = self.context['request'].user
        user.set_password(self.validated_data['new_password'])
        user.save()


class UserDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model  = UserDocument
        fields = ('id', 'doc_type', 'file', 'is_verified', 'uploaded_at')
        read_only_fields = ('id', 'is_verified', 'uploaded_at')


class SavedAddressSerializer(serializers.ModelSerializer):
    class Meta:
        model  = SavedAddress
        fields = ('id', 'label', 'address', 'latitude', 'longitude', 'is_default', 'created_at')
        read_only_fields = ('id', 'created_at')
