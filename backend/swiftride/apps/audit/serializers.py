from rest_framework import serializers
from .models import AuditLog
from swiftride.apps.users.serializers import UserMiniSerializer


class AuditLogSerializer(serializers.ModelSerializer):
    actor = UserMiniSerializer(read_only=True)
    class Meta:
        model  = AuditLog
        fields = '__all__'
