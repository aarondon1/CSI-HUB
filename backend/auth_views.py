# backend/auth_views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import User
import json
import logging

logger = logging.getLogger(__name__)

@csrf_exempt
def supabase_auth(request):
    """
    Simple authentication endpoint that creates/retrieves a token based on Supabase user ID
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Only POST method is allowed'}, status=405)
    
    try:
        # Log the raw request body for debugging
        logger.info(f"Request body: {request.body}")
        
        # Handle empty request body
        if not request.body:
            return JsonResponse({'error': 'Empty request body'}, status=400)
        
        # Parse JSON body
        try:
            data = json.loads(request.body)
        except json.JSONDecodeError as e:
            logger.error(f"JSON decode error: {str(e)}")
            return JsonResponse({'error': f"Invalid JSON: {str(e)}"}, status=400)
        
        # Extract user_id from data
        user_id = data.get('user_id')
        supabase_token = data.get('supabase_token')
        email = data.get('email', '')
                
        if not user_id:
            return JsonResponse({'error': 'user_id is required'}, status=400)
        
        # Get or create a user based on the Supabase user ID
        user, created = User.objects.get_or_create(
            username=user_id,
            defaults={'email': email}
        )
        
        # Get or create a token for this user
        token, created = Token.objects.get_or_create(user=user)
        
        # Log success
        logger.info(f"Authentication successful for user_id={user_id}")
        
        return JsonResponse({
            'token': token.key,
            'user_id': user.username,
        })
    except Exception as e:
        logger.error(f"Authentication error: {str(e)}")
        return JsonResponse({'error': str(e)}, status=500)