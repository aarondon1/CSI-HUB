import jwt
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.conf import settings
from .models import Profile
import logging

logger = logging.getLogger(__name__)

class SupabaseAuthentication(BaseAuthentication):
    """
    Custom authentication class for validating Supabase JWT tokens.
    """
    
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return None
            
        token = auth_header.split(' ')[1]
        
        try:
            # Decode the JWT token using the SUPABASE_JWT_SECRET
            payload = jwt.decode(
                token,
                settings.SUPABASE_JWT_SECRET,
                algorithms=["HS256"],
                options={"verify_aud": False}  # Ignore audience verification
            )
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed('Token expired')
        except jwt.InvalidTokenError as e:
            raise AuthenticationFailed(f'Invalid token: {str(e)}')
            
        # Get user_id from the token (Supabase uses 'sub' for user ID)
        user_id = payload.get('sub')
        if not user_id:
            raise AuthenticationFailed('Invalid token payload: missing sub (user_id)')
            
        # Get email from token if available
        email = payload.get('email', '')
        
        # Get or create profile based on the user_id
        try:
            profile, created = Profile.objects.get_or_create(
                user_id=user_id,
                defaults={
                    'email': email,
                    'username': email.split('@')[0] if email else f'user_{user_id[:8]}'
                }
            )
            
            # Add is_authenticated attribute to the profile
            profile.is_authenticated = True
            
            # Add username attribute if it's not set
            if not profile.username:
                profile.username = email.split('@')[0] if email else f'user_{user_id[:8]}'
                profile.save(update_fields=['username'])
                
        except Exception as e:
            raise AuthenticationFailed(f'Profile error: {str(e)}')
            
        # Return profile and token payload
        return (profile, payload)
    
    def authenticate_header(self, request):
        return 'Bearer'