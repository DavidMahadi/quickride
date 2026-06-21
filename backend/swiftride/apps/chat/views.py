from drf_spectacular.utils import extend_schema
from rest_framework import generics, status
from rest_framework.response import Response
from .models import Conversation, Message
from .serializers import ConversationSerializer, MessageSerializer


@extend_schema(tags=['Chat'])
class ConversationListView(generics.ListCreateAPIView):
    serializer_class = ConversationSerializer

    def get_queryset(self):
        user = self.request.user
        if user.role in ('company_staff', 'company_admin'):
            return Conversation.objects.filter(company=user.company)
        return Conversation.objects.filter(customer=user)

    def create(self, request, *args, **kwargs):
        company_id = request.data.get('company')
        convo, created = Conversation.objects.get_or_create(
            customer=request.user,
            company_id=company_id
        )
        return Response(ConversationSerializer(convo, context={'request': request}).data,
                        status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


@extend_schema(tags=['Chat'])
class MessageListView(generics.ListCreateAPIView):
    serializer_class = MessageSerializer

    def get_queryset(self):
        return Message.objects.filter(
            conversation_id=self.kwargs['convo_pk']
        ).select_related('sender')

    def perform_create(self, serializer):
        convo = Conversation.objects.get(pk=self.kwargs['convo_pk'])
        msg   = serializer.save(sender=self.request.user, conversation=convo)
        convo.save()  # update updated_at
        # Mark all others' messages as read
        convo.messages.exclude(sender=self.request.user).update(is_read=True)

from drf_spectacular.utils import extend_schema

ConversationListView = extend_schema(tags=['Chat'], summary='List conversations / start a new one')(ConversationListView)
MessageListView      = extend_schema(tags=['Chat'], summary='Get messages / send a message in a conversation')(MessageListView)
