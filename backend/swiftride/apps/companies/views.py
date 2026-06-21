from drf_spectacular.utils import extend_schema
from rest_framework import generics, status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.utils import timezone
from swiftride.apps.audit.utils import log_action
from .models import Company, CompanyDocument
from .serializers import CompanySerializer, CompanyMiniSerializer, CompanyDocumentSerializer
from .permissions import IsSuperAdmin, IsCompanyAdmin


@extend_schema(tags=['Companies'])
class CompanyListView(generics.ListAPIView):
    serializer_class   = CompanyMiniSerializer
    permission_classes = [permissions.AllowAny]
    queryset           = Company.objects.filter(status='active')
    search_fields      = ['name', 'location']
    filterset_fields   = ['rental_model']


@extend_schema(tags=['Companies'])
class CompanyCreateView(generics.CreateAPIView):
    serializer_class   = CompanySerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        company = serializer.save()
        log_action(self.request.user, 'create', 'Company', str(company.id),
                   f'Company {company.name} registered')


@extend_schema(tags=['Companies'])
class CompanyDetailView(generics.RetrieveUpdateAPIView):
    serializer_class   = CompanySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return Company.objects.all()

    def update(self, request, *args, **kwargs):
        company = self.get_object()
        # Only the company admin of this company or super admin can update
        if not (request.user.is_super_admin or
                (request.user.is_company_admin and request.user.company == company)):
            return Response({'detail': 'Permission denied.'}, status=403)
        return super().update(request, *args, **kwargs)


@extend_schema(tags=['Companies'])
class CompanyApproveView(generics.GenericAPIView):
    permission_classes = [IsSuperAdmin]

    def post(self, request, pk):
        company = Company.objects.get(pk=pk)
        company.status      = Company.Status.ACTIVE
        company.approved_by = request.user
        company.approved_at = timezone.now()
        company.save()
        log_action(request.user, 'approve', 'Company', str(company.id),
                   f'Company {company.name} approved')
        return Response({'detail': 'Company approved.'})


@extend_schema(tags=['Companies'])
class CompanySuspendView(generics.GenericAPIView):
    permission_classes = [IsSuperAdmin]

    def post(self, request, pk):
        company = Company.objects.get(pk=pk)
        company.status = Company.Status.SUSPENDED
        company.save()
        log_action(request.user, 'suspend', 'Company', str(company.id),
                   f'Company {company.name} suspended')
        return Response({'detail': 'Company suspended.'})


@extend_schema(tags=['Companies'])
class MyCompanyView(generics.RetrieveUpdateAPIView):
    serializer_class   = CompanySerializer
    permission_classes = [IsCompanyAdmin]

    def get_object(self):
        return self.request.user.company


@extend_schema(tags=['Companies'])
class CompanyDocumentView(generics.ListCreateAPIView):
    serializer_class   = CompanyDocumentSerializer
    permission_classes = [IsCompanyAdmin]

    def get_queryset(self):
        return CompanyDocument.objects.filter(company=self.request.user.company)

    def perform_create(self, serializer):
        serializer.save(company=self.request.user.company)
# Swagger tags added via decorators below

from drf_spectacular.utils import extend_schema

# Patch tags onto existing views
CompanyListView      = extend_schema(tags=['Companies'], summary='List all active companies (public)')(CompanyListView)
CompanyCreateView    = extend_schema(tags=['Companies'], summary='Register a new company')(CompanyCreateView)
CompanyDetailView    = extend_schema(tags=['Companies'], summary='Get or update company details')(CompanyDetailView)
CompanyApproveView   = extend_schema(tags=['Admin'],     summary='Approve a pending company')(CompanyApproveView)
CompanySuspendView   = extend_schema(tags=['Admin'],     summary='Suspend an active company')(CompanySuspendView)
MyCompanyView        = extend_schema(tags=['Companies'], summary='Get / update my company profile')(MyCompanyView)
CompanyDocumentView  = extend_schema(tags=['Companies'], summary='List / upload company documents')(CompanyDocumentView)
