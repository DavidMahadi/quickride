from drf_spectacular.utils import extend_schema
from rest_framework import generics
from swiftride.apps.companies.permissions import IsSuperAdmin, IsCompanyAdmin
from .models import AuditLog
from .serializers import AuditLogSerializer


@extend_schema(tags=['Audit'])
class AuditLogListView(generics.ListAPIView):
    serializer_class   = AuditLogSerializer
    permission_classes = [IsSuperAdmin]
    queryset           = AuditLog.objects.all().select_related('actor')
    filterset_fields   = ['action', 'entity_type', 'actor']
    search_fields      = ['description', 'entity_id']
    ordering_fields    = ['created_at']


@extend_schema(tags=['Audit'])
class MyAuditLogView(generics.ListAPIView):
    """Company staff can see their own audit trail."""
    serializer_class = AuditLogSerializer
    permission_classes = [IsCompanyAdmin]

    def get_queryset(self):
        return AuditLog.objects.filter(actor=self.request.user)

from drf_spectacular.utils import extend_schema

AuditLogListView = extend_schema(tags=['Audit'], summary='List all audit logs (super admin only)')(AuditLogListView)
MyAuditLogView   = extend_schema(tags=['Audit'], summary='List my own activity audit trail')(MyAuditLogView)
