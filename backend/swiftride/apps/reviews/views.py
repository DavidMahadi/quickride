from drf_spectacular.utils import extend_schema
from rest_framework import generics, permissions
from rest_framework.response import Response
from django.utils import timezone
from swiftride.apps.companies.permissions import IsCompanyStaff
from .models import Review
from .serializers import ReviewSerializer, ReviewReplySerializer


@extend_schema(tags=['Reviews'])
class CreateReviewView(generics.CreateAPIView):
    serializer_class = ReviewSerializer

    def perform_create(self, serializer):
        serializer.save()


@extend_schema(tags=['Reviews'])
class CarReviewsView(generics.ListAPIView):
    serializer_class   = ReviewSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        return Review.objects.filter(car_id=self.kwargs['car_pk'], is_public=True)


@extend_schema(tags=['Reviews'])
class CompanyReviewsView(generics.ListAPIView):
    serializer_class   = ReviewSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        return Review.objects.filter(company_id=self.kwargs['company_pk'], is_public=True)


@extend_schema(tags=['Reviews'])
class ReplyReviewView(generics.GenericAPIView):
    serializer_class   = ReviewReplySerializer
    permission_classes = [IsCompanyStaff]

    def post(self, request, pk):
        review = Review.objects.get(pk=pk, company=request.user.company)
        s = self.get_serializer(data=request.data)
        s.is_valid(raise_exception=True)
        review.reply      = s.validated_data['reply']
        review.replied_by = request.user
        review.replied_at = timezone.now()
        review.save(update_fields=['reply', 'replied_by', 'replied_at'])
        return Response(ReviewSerializer(review).data)

from drf_spectacular.utils import extend_schema

CreateReviewView   = extend_schema(tags=['Reviews'], summary='Submit a review for a completed booking')(CreateReviewView)
CarReviewsView     = extend_schema(tags=['Reviews'], summary='List reviews for a specific car (public)')(CarReviewsView)
CompanyReviewsView = extend_schema(tags=['Reviews'], summary='List reviews for a specific company (public)')(CompanyReviewsView)
ReplyReviewView    = extend_schema(tags=['Reviews'], summary='Company staff reply to a review')(ReplyReviewView)
