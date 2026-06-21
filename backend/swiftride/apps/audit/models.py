# apps/audit/models.py
import uuid
from django.db import models


class AuditLog(models.Model):
    class Action(models.TextChoices):
        CREATE   = 'create',   'Create'
        UPDATE   = 'update',   'Update'
        DELETE   = 'delete',   'Delete'
        LOGIN    = 'login',    'Login'
        LOGOUT   = 'logout',   'Logout'
        APPROVE  = 'approve',  'Approve'
        SUSPEND  = 'suspend',  'Suspend'
        EXPORT   = 'export',   'Export'

    id           = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    actor        = models.ForeignKey(
        'users.User', null=True, on_delete=models.SET_NULL, related_name='audit_logs'
    )
    action       = models.CharField(max_length=15, choices=Action.choices)
    entity_type  = models.CharField(max_length=50)   # e.g. 'Booking', 'Car'
    entity_id    = models.CharField(max_length=50, blank=True)
    description  = models.TextField()
    meta         = models.JSONField(default=dict, blank=True)  # before/after snapshots
    ip_address   = models.GenericIPAddressField(null=True, blank=True)
    user_agent   = models.TextField(blank=True)
    created_at   = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'audit_logs'
        ordering = ['-created_at']
        indexes  = [
            models.Index(fields=['actor',       'created_at']),
            models.Index(fields=['entity_type', 'entity_id']),
            models.Index(fields=['action',      'created_at']),
        ]

    def __str__(self):
        return f'{self.actor} {self.action} {self.entity_type}({self.entity_id})'
