from rest_framework.permissions import BasePermission

class IsAuthenticatedWithProfile(BasePermission):
    """
    Permission class that works with Profile objects.
    """
    def has_permission(self, request, view):
        return bool(request.user and hasattr(request.user, 'user_id'))