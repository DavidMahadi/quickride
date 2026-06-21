from drf_spectacular.utils import extend_schema
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from .models import Notification
from .serializers import NotificationSerializer


@extend_schema(tags=['Notifications'])
class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer

    def get_queryset(self):
        return Notification.objects.filter(user=self.request.user)


@extend_schema(tags=['Notifications'])
class MarkReadView(generics.GenericAPIView):
    def post(self, request, pk):
        notif = Notification.objects.get(pk=pk, user=request.user)
        notif.is_read = True
        notif.save(update_fields=['is_read'])
        return Response({'detail': 'Marked as read.'})


@extend_schema(tags=['Notifications'])
class MarkAllReadView(generics.GenericAPIView):
    def post(self, request):
        Notification.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'detail': 'All notifications marked as read.'})

from drf_spectacular.utils import extend_schema

NotificationListView = extend_schema(tags=['Notifications'], summary='List my notifications')(NotificationListView)
MarkReadView         = extend_schema(tags=['Notifications'], summary='Mark a notification as read')(MarkReadView)
MarkAllReadView      = extend_schema(tags=['Notifications'], summary='Mark all notifications as read')(MarkAllReadView)
