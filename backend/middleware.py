import logging
import json
from django.utils.deprecation import MiddlewareMixin

logger = logging.getLogger(__name__)

class RequestLoggingMiddleware(MiddlewareMixin):
    """
    Middleware to log requests and responses with reduced verbosity for security.
    """
    
    def process_request(self, request):
        logger.debug(f"Request: {request.method} {request.path}")
        # Don't log headers or request bodies in production
        return None
        
    def process_response(self, request, response):
        status_code = getattr(response, 'status_code', None)
        logger.debug(f"Response: {request.method} {request.path} - {status_code}")
        
        # Only log minimal error information
        if status_code and status_code >= 500:
            logger.error(f"Server error: {request.method} {request.path} - {status_code}")
                
        return response