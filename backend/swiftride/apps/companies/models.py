# apps/companies/models.py
import uuid
from django.db import models


class Company(models.Model):
    class Status(models.TextChoices):
        PENDING  = 'pending',  'Pending Approval'
        ACTIVE   = 'active',   'Active'
        SUSPENDED= 'suspended','Suspended'
        INACTIVE = 'inactive', 'Inactive'

    class RentalModel(models.TextChoices):
        PER_DAY    = 'per_day',    'Per Day'
        PER_MONTH  = 'per_month',  'Per Month'
        LONG_TERM  = 'long_term',  'Long Term (6 months+)'
        HYBRID     = 'hybrid',     'Hybrid (Daily & Monthly)'

    id               = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name             = models.CharField(max_length=150, unique=True)
    slug             = models.SlugField(max_length=160, unique=True)
    description      = models.TextField(blank=True)
    logo             = models.ImageField(upload_to='company_logos/', null=True, blank=True)
    cover_image      = models.ImageField(upload_to='company_covers/', null=True, blank=True)

    # Contact
    email            = models.EmailField()
    phone            = models.CharField(max_length=20)
    location         = models.TextField()
    latitude         = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude        = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    # Business
    registration_no  = models.CharField(max_length=50, unique=True)
    rental_model     = models.CharField(max_length=20, choices=RentalModel.choices, default=RentalModel.PER_DAY)
    status           = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)

    # Stats (denormalized for speed)
    total_cars       = models.PositiveIntegerField(default=0)
    available_cars   = models.PositiveIntegerField(default=0)
    avg_rating       = models.DecimalField(max_digits=3, decimal_places=2, default=0.00)
    total_bookings   = models.PositiveIntegerField(default=0)
    total_revenue    = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)

    # Metadata
    created_at       = models.DateTimeField(auto_now_add=True)
    updated_at       = models.DateTimeField(auto_now=True)
    approved_at      = models.DateTimeField(null=True, blank=True)
    approved_by      = models.ForeignKey(
        'users.User', null=True, blank=True,
        on_delete=models.SET_NULL,
        related_name='approved_companies'
    )

    class Meta:
        db_table  = 'companies'
        ordering  = ['-created_at']
        verbose_name_plural = 'companies'

    def __str__(self):
        return self.name


class CompanyDocument(models.Model):
    """Legal / business documents submitted by companies."""
    class DocType(models.TextChoices):
        BUSINESS_REG    = 'business_reg',    'Business Registration'
        INSURANCE       = 'insurance',       'Insurance Certificate'
        TAX_CLEARANCE   = 'tax_clearance',   'Tax Clearance'
        OTHER           = 'other',           'Other'

    id          = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    company     = models.ForeignKey(Company, on_delete=models.CASCADE, related_name='documents')
    doc_type    = models.CharField(max_length=20, choices=DocType.choices)
    file        = models.FileField(upload_to='company_documents/')
    is_verified = models.BooleanField(default=False)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'company_documents'

    def __str__(self):
        return f'{self.company.name} — {self.doc_type}'
