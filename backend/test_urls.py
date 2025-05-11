# backend/test_urls.py
from django.urls import path
from . import test_views

# These URLs are only for testing purposes
urlpatterns = [
    path('api/test/auth/', test_views.auth_test, name='test_auth'),
    path('api/test/profile/', test_views.profile_test, name='test_profile'),
    path('api/test/drf-auth/', test_views.drf_auth_test, name='test_drf_auth'),
    path('api/test/token/', test_views.token_debug, name='test_token'),
]