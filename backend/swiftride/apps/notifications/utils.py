from .models import Notification


def send_notification(user, notif_type, title, body, data=None):
    """Create a notification record. Extend to push via FCM/WebSocket."""
    Notification.objects.create(
        user=user, type=notif_type, title=title, body=body, data=data or {}
    )
