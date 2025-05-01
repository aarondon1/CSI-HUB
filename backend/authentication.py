import jwt
from rest_framework.response import Response
from functools import wraps
import os
from dotenv import load_dotenv
from .models import Profile

# Load environment variables
load_dotenv()

SUPABASE_JWT_SECRET = os.getenv("SUPABASE_JWT_SECRET")

if not SUPABASE_JWT_SECRET:
    raise ValueError("Missing SUPABASE_JWT_SECRET in environment variables")

def authentication_required(view_func):
    @wraps(view_func)
    def _wrapped_view(view_instance, request, *args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return Response({'error': 'Authorization header missing or invalid'}, status=401)

        token = auth_header.split(' ')[1]

        try:
            payload = jwt.decode(
                token,
                SUPABASE_JWT_SECRET,
                algorithms=["HS256"],
                options={"verify_aud": False}  # Ignore audience
            )
        except jwt.ExpiredSignatureError:
            return Response({'error': 'Token expired'}, status=401)
        except jwt.InvalidTokenError:
            return Response({'error': 'Invalid token'}, status=401)

        # Safely extract user_id
        user_id = payload.get('sub')
        if not user_id:
            return Response({'error': 'Invalid token payload: missing sub (user_id)'}, status=401)

        email = payload.get('email', '')

        # Fetch or create Profile
        profile, created = Profile.objects.get_or_create(
            user_id=user_id,
            defaults={
                'email': email,
                'username': email.split('@')[0] if email else f'user_{user_id[:8]}'
            }
        )

        request.user_info = payload
        request.profile = profile
        return view_func(view_instance, request, *args, **kwargs)

    return _wrapped_view
