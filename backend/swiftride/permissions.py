# swiftride/permissions.py
from rest_framework.permissions import BasePermission

class IsSuperAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'super_admin'

class IsCompanyAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ('company_admin', 'super_admin')

class IsCompanyStaff(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ('company_staff', 'company_admin', 'super_admin')

class IsClient(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'client'

class IsOwnerOrAdmin(BasePermission):
    """Object-level: user owns the resource or is admin/super_admin."""
    def has_object_permission(self, request, view, obj):
        if request.user.role in ('super_admin', 'company_admin'):
            return True
        owner = getattr(obj, 'customer', None) or getattr(obj, 'user', None)
        return owner == request.user

class BelongsToSameCompany(BasePermission):
    """Staff/admin can only access their own company's resources."""
    def has_object_permission(self, request, view, obj):
        if request.user.role == 'super_admin':
            return True
        company = getattr(obj, 'company', None)
        if company is None:
            return False
        return request.user.company == company
