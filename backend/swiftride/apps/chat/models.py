# apps/chat/models.py
import uuid
from django.db import models


class Conversation(models.Model):
    """A chat thread between a customer and a company."""
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    customer   = models.ForeignKey(
        'users.User', on_delete=models.CASCADE, related_name='conversations'
    )
    company    = models.ForeignKey(
        'companies.Company', on_delete=models.CASCADE, related_name='conversations'
    )
    booking    = models.ForeignKey(
        'bookings.Booking', null=True, blank=True,
        on_delete=models.SET_NULL, related_name='conversations'
    )
    is_active  = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table        = 'conversations'
        unique_together = ('customer', 'company')
        ordering        = ['-updated_at']

    def __str__(self):
        return f'{self.customer.full_name} ↔ {self.company.name}'

    @property
    def last_message(self):
        return self.messages.order_by('-created_at').first()


class Message(models.Model):
    class MsgType(models.TextChoices):
        TEXT     = 'text',     'Text'
        IMAGE    = 'image',    'Image'
        FILE     = 'file',     'File'
        SYSTEM   = 'system',   'System'

    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender       = models.ForeignKey(
        'users.User', on_delete=models.CASCADE, related_name='messages_sent'
    )
    msg_type     = models.CharField(max_length=10, choices=MsgType.choices, default=MsgType.TEXT)
    text         = models.TextField(blank=True)
    file         = models.FileField(upload_to='chat_files/', null=True, blank=True)
    is_read      = models.BooleanField(default=False)
    created_at   = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'messages'
        ordering = ['created_at']
        indexes  = [models.Index(fields=['conversation', 'created_at'])]

    def __str__(self):
        return f'{self.sender.full_name}: {self.text[:40]}'
