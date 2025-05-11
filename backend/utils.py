from rest_framework.views import exception_handler
from rest_framework.response import Response
import logging
import traceback

logger = logging.getLogger(__name__)

def custom_exception_handler(exc, context):
    """
    Custom exception handler for better error reporting.
    """
    # Log the error
    logger.error(f"Exception: {exc}")
    logger.error(traceback.format_exc())
    
    # Get the view and request
    view = context.get('view')
    request = context.get('request')
    
    if view:
        logger.error(f"View: {view.__class__.__name__}")
    
    if request:
        logger.error(f"URL: {request.path}")
        logger.error(f"Method: {request.method}")
        logger.error(f"User: {getattr(request, 'user', 'AnonymousUser')}")
    
    # Call REST framework's default exception handler first
    response = exception_handler(exc, context)
    
    # If this is a 500 error or another unhandled exception
    if response is None:
        return Response(
            {"detail": "Internal server error", "message": str(exc)},
            status=500
        )
        
    # Add more context to authentication errors
    if response.status_code in (401, 403):
        if hasattr(exc, 'detail'):
            response.data = {
                "detail": str(exc.detail),
                "code": getattr(exc, 'code', 'authentication_failed')
            }
            
    return response