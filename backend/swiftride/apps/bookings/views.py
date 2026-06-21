# apps/bookings/views.py
from rest_framework import generics, status, permissions
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiExample, OpenApiParameter
from drf_spectacular.types import OpenApiTypes
from swiftride.apps.companies.permissions import IsCompanyStaff, IsSuperAdmin
from swiftride.apps.audit.utils import log_action
from .models import Booking, BookingStatusLog
from .serializers import BookingSerializer, CreateBookingSerializer, BookingMiniSerializer


@extend_schema(
    tags=['Bookings'],
    summary='Create a new booking',
    description='Customer creates a booking for an available car. Price is calculated automatically from car rate × days.',
    examples=[
        OpenApiExample('Example request', value={
            'car': 'car-uuid-here',
            'pickup_date': '2026-07-01T10:00:00Z',
            'return_date': '2026-07-04T10:00:00Z',
            'pickup_location': 'Kigali International Airport',
            'dropoff_location': 'Kigali City Centre',
            'payment_method': 'mobile_mtn',
            'notes': 'Please have the car ready at the terminal exit.'
        }, request_only=True)
    ]
)
class CreateBookingView(generics.CreateAPIView):
    serializer_class = CreateBookingSerializer

    def perform_create(self, serializer):
        booking = serializer.save()
        log_action(self.request.user, 'create', 'Booking', str(booking.id),
                   f'Booking {booking.ref} created')


@extend_schema(
    tags=['Bookings'],
    summary='List my bookings',
    parameters=[OpenApiParameter('status', OpenApiTypes.STR,
        description='Filter: pending | confirmed | active | completed | cancelled')]
)
class MyBookingsView(generics.ListAPIView):
    serializer_class = BookingMiniSerializer

    def get_queryset(self):
        qs = Booking.objects.filter(customer=self.request.user).select_related('car', 'company')
        s  = self.request.query_params.get('status')
        if s: qs = qs.filter(status=s)
        return qs


@extend_schema(tags=['Bookings'], summary='Get full booking details including status history')
class BookingDetailView(generics.RetrieveAPIView):
    serializer_class = BookingSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_super_admin:
            return Booking.objects.all()
        if user.role in ('company_admin', 'company_staff'):
            return Booking.objects.filter(company=user.company)
        return Booking.objects.filter(customer=user)


@extend_schema(
    tags=['Bookings'],
    summary='Cancel a booking',
    description='Customer can cancel a booking while it is still pending or confirmed.',
    examples=[OpenApiExample('Example', value={'reason': 'Change of plans'}, request_only=True)]
)
class CancelBookingView(generics.GenericAPIView):
    def post(self, request, pk):
        booking = Booking.objects.get(pk=pk, customer=request.user)
        if booking.status not in ('pending', 'confirmed'):
            return Response({'detail': 'Cannot cancel this booking.'}, status=400)
        reason = request.data.get('reason', '')
        booking.cancel(reason)
        booking.car.status = 'available'
        booking.car.save(update_fields=['status'])
        BookingStatusLog.objects.create(
            booking=booking, from_status='confirmed',
            to_status='cancelled', changed_by=request.user, note=reason
        )
        log_action(request.user, 'update', 'Booking', str(booking.id), f'{booking.ref} cancelled')
        return Response({'detail': 'Booking cancelled.'})


@extend_schema(
    tags=['Company Bookings'],
    summary='List all bookings for this company',
    parameters=[OpenApiParameter('status', OpenApiTypes.STR, description='Filter by status')]
)
class CompanyBookingListView(generics.ListAPIView):
    serializer_class   = BookingSerializer
    permission_classes = [IsCompanyStaff]

    def get_queryset(self):
        qs = Booking.objects.filter(company=self.request.user.company).select_related('customer', 'car')
        s  = self.request.query_params.get('status')
        if s: qs = qs.filter(status=s)
        return qs


@extend_schema(
    tags=['Company Bookings'],
    summary='Update booking status',
    description='Staff can move a booking through: confirmed → active → completed. They can also cancel.',
    examples=[
        OpenApiExample('Confirm booking',   value={'status': 'confirmed', 'note': 'Car ready'}, request_only=True),
        OpenApiExample('Mark as active',    value={'status': 'active',    'note': 'Customer picked up'}, request_only=True),
        OpenApiExample('Mark as completed', value={'status': 'completed', 'note': 'Returned in good condition'}, request_only=True),
    ]
)
class UpdateBookingStatusView(generics.GenericAPIView):
    permission_classes = [IsCompanyStaff]

    def post(self, request, pk):
        booking    = Booking.objects.get(pk=pk, company=request.user.company)
        new_status = request.data.get('status')
        allowed    = ('confirmed', 'active', 'completed', 'cancelled')
        if new_status not in allowed:
            return Response({'detail': f'Status must be one of {allowed}'}, status=400)
        old_status     = booking.status
        booking.status = new_status
        booking.save(update_fields=['status', 'updated_at'])
        if new_status == 'completed':
            booking.car.status       = 'available'
            booking.car.total_trips += 1
            booking.car.save(update_fields=['status', 'total_trips'])
        BookingStatusLog.objects.create(
            booking=booking, from_status=old_status, to_status=new_status,
            changed_by=request.user, note=request.data.get('note', '')
        )
        log_action(request.user, 'update', 'Booking', str(booking.id),
                   f'{booking.ref}: {old_status} → {new_status}')
        return Response({'detail': f'Status updated to {new_status}.'})


@extend_schema(
    tags=['Admin'],
    summary='List all platform bookings (super admin only)',
    parameters=[
        OpenApiParameter('status',         OpenApiTypes.STR, description='Filter by status'),
        OpenApiParameter('payment_status', OpenApiTypes.STR, description='Filter by payment status'),
        OpenApiParameter('company',        OpenApiTypes.STR, description='Filter by company UUID'),
    ]
)
class AdminBookingListView(generics.ListAPIView):
    serializer_class   = BookingSerializer
    permission_classes = [IsSuperAdmin]
    queryset           = Booking.objects.all().select_related('customer', 'car', 'company')
    filterset_fields   = ['status', 'payment_status', 'company']
    search_fields      = ['ref', 'customer__full_name', 'car__name']
