from rest_framework import serializers
from .models import Conversation, Message
from swiftride.apps.users.serializers import UserMiniSerializer
from swiftride.apps.companies.serializers import CompanyMiniSerializer


class MessageSerializer(serializers.ModelSerializer):
    sender = UserMiniSerializer(read_only=True)
    class Meta:
        model  = Message
        fields = ('id', 'sender', 'msg_type', 'text', 'file', 'is_read', 'created_at')
        read_only_fields = ('id', 'sender', 'is_read', 'created_at')


class ConversationSerializer(serializers.ModelSerializer):
    customer     = UserMiniSerializer(read_only=True)
    company_detail = CompanyMiniSerializer(source='company', read_only=True)
    last_message = MessageSerializer(read_only=True)
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model  = Conversation
        fields = ('id', 'customer', 'company_detail', 'last_message',
                  'unread_count', 'is_active', 'created_at', 'updated_at')

    def get_unread_count(self, obj):
        user = self.context['request'].user
        return obj.messages.filter(is_read=False).exclude(sender=user).count()
