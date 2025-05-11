# backend/test_views.py

"""
Test views for debugging and testing purposes.
These views should not be exposed in production.
"""

import logging
import jwt
from django.conf import settings
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from .authentication import SupabaseAuthentication
from .permissions import IsAuthenticatedWithProfile

logger = logging.getLogger(__name__)

@api_view(['GET'])
@permission_classes([AllowAny])
def auth_test(request):
    """
    Test endpoint to verify authentication is working.
    """
    auth_header = request.headers.get('Authorization')
    
    return Response({
        "authenticated": hasattr(request.user, 'is_authenticated') and request.user.is_authenticated,
        "user_id": getattr(request.user, 'user_id', None),
        "username": getattr(request.user, 'username', None),
        "auth_header_present": auth_header is not None,
    })

@api_view(['GET'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def profile_test(request):
    """
    Test endpoint to verify profile authentication is working.
    """
    return Response({
        "authenticated": True,
        "user_id": request.user.user_id,
        "username": request.user.username,
        "email": getattr(request.user, 'email', None),
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def drf_auth_test(request):
    """
    Test endpoint to verify DRF IsAuthenticated permission is working.
    """
    return Response({
        "authenticated": True,
        "user_id": getattr(request.user, 'user_id', None),
        "username": getattr(request.user, 'username', None),
    })

@api_view(['GET'])
@permission_classes([AllowAny])
def token_debug(request):
    """
    Debug endpoint to check token details.
    """
    auth_header = request.headers.get('Authorization')
    
    if not auth_header or not auth_header.startswith('Bearer '):
        return Response({
            "error": "No valid Authorization header found",
            "headers": dict(request.headers)
        })
        
    token = auth_header.split(' ')[1]
    
    try:
        # Just try to decode without validation
        payload = jwt.decode(
            token,
            options={"verify_signature": False}
        )
        
        # Try to decode with validation
        try:
            validated_payload = jwt.decode(
                token,
                settings.SUPABASE_JWT_SECRET,
                algorithms=["HS256"],
                options={"verify_aud": False}
            )
            validation_success = True
            validation_error = None
        except Exception as e:
            validation_success = False
            validation_error = str(e)
        
        return Response({
            "token_valid": True,
            "payload": payload,
            "token_first_20_chars": token[:20] + "...",
            "supabase_secret_first_5_chars": settings.SUPABASE_JWT_SECRET[:5] + "...",
            "validation_success": validation_success,
            "validation_error": validation_error
        })
    except Exception as e:
        return Response({
            "token_valid": False,
            "error": str(e),
            "token_first_20_chars": token[:20] + "..."
        })