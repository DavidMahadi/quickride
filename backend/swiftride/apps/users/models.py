# apps/users/models.py
import uuid
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra):
        if not email:
            raise ValueError('Email is required')
        email = self.normalize_email(email)
        user  = self.model(email=email, **extra)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password, **extra):
        extra.setdefault('role', 'super_admin')
        extra.setdefault('is_staff', True)
        extra.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra)


class User(AbstractBaseUser, PermissionsMixin):
    class Role(models.TextChoices):
        CUSTOMER      = 'customer',      'Customer'
        COMPANY_STAFF = 'company_staff', 'Company Staff'
        COMPANY_ADMIN = 'company_admin', 'Company Admin'
        SUPER_ADMIN   = 'super_admin',   'Super Admin'

    id            = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email         = models.EmailField(unique=True)
    full_name     = models.CharField(max_length=150)
    phone         = models.CharField(max_length=20, blank=True)
    role          = models.CharField(max_length=20, choices=Role.choices, default=Role.CUSTOMER)
    avatar        = models.ImageField(upload_to='avatars/', null=True, blank=True)

    # Driver info (for customers)
    driver_license_no   = models.CharField(max_length=50, blank=True)
    driver_license_expiry = models.DateField(null=True, blank=True)
    date_of_birth       = models.DateField(null=True, blank=True)
    national_id         = models.CharField(max_length=50, blank=True)

    # Company link (for staff & company admin)
    company = models.ForeignKey(
        'companies.Company',
        null=True, blank=True,
        on_delete=models.SET_NULL,
        related_name='staff_members'
    )
    job_title = models.CharField(max_length=100, blank=True)

    # Status
    is_active    = models.BooleanField(default=True)
    is_staff     = models.BooleanField(default=False)
    is_verified  = models.BooleanField(default=False)
    created_at   = models.DateTimeField(auto_now_add=True)
    updated_at   = models.DateTimeField(auto_now=True)

    USERNAME_FIELD  = 'email'
    REQUIRED_FIELDS = ['full_name']
    objects         = UserManager()

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.full_name} <{self.email}> [{self.role}]'

    @property
    def is_customer(self):      return self.role == self.Role.CUSTOMER
    @property
    def is_company_staff(self): return self.role == self.Role.COMPANY_STAFF
    @property
    def is_company_admin(self): return self.role == self.Role.COMPANY_ADMIN
    @property
    def is_super_admin(self):   return self.role == self.Role.SUPER_ADMIN


class UserDocument(models.Model):
    """Uploaded KYC / license documents for customers."""
    class DocType(models.TextChoices):
        NATIONAL_ID     = 'national_id',     'National ID'
        DRIVER_LICENSE  = 'driver_license',  'Driver License'
        PASSPORT        = 'passport',        'Passport'

    id          = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user        = models.ForeignKey(User, on_delete=models.CASCADE, related_name='documents')
    doc_type    = models.CharField(max_length=20, choices=DocType.choices)
    file        = models.FileField(upload_to='documents/')
    is_verified = models.BooleanField(default=False)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'user_documents'
        unique_together = ('user', 'doc_type')

    def __str__(self):
        return f'{self.user.full_name} — {self.doc_type}'


class SavedAddress(models.Model):
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user       = models.ForeignKey(User, on_delete=models.CASCADE, related_name='saved_addresses')
    label      = models.CharField(max_length=50)   # e.g. Home, Office
    address    = models.TextField()
    latitude   = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude  = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'saved_addresses'

    def __str__(self):
        return f'{self.user.full_name} — {self.label}'
