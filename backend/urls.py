# backend/urls.py
from django.urls import path, include
from django.conf import settings
from . import views
from . auth_views import supabase_auth

urlpatterns = [
    # Root path
    path('', views.myapp),

    # Profiles
    path('create-profile/', views.create_profile),
    path('profile/<str:user_id>/', views.profile_detail),  # Handles both GET and PATCH
    path('me/', views.get_current_user),  # Add this function

    # Projects
    path('create-project/', views.create_project),
    path('projects/<int:pk>/', views.project_detail),  # GET, PUT, DELETE
    path('user-projects/<str:user_id>/', views.get_user_projects),
    path('homepage/', views.get_projects),  # GET with ?query=

    # Join-requests 
    path('join-request/<int:pk>/status/', views.update_join_request_status),
    path('join-request/', views.create_join_request),
    path('join-request/user/<str:user_id>/', views.get_received_join_requests),
    path('join-request/sent/', views.get_sent_join_requests),
    
    path('api/auth/', supabase_auth, name='supabase_auth'), # Authentication endpoint
]


# Include test URLs only in debug mode
if settings.DEBUG:
    from backend import test_urls
    urlpatterns += [
        path('', include(test_urls)),
    ]