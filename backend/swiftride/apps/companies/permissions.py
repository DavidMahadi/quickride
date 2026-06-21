from rest_framework.permissions import BasePermission

class IsCompanyAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ('company_admin', 'super_admin')

class IsCompanyStaff(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ('company_staff', 'company_admin', 'super_admin')

class IsSuperAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'super_admin'
