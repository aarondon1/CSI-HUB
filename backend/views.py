from django.shortcuts import render, get_object_or_404
from django.db.models import Q
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from .models import Profile, Project, JoinRequest
from .serializers import ProfileSerializer, ProjectSerializer, JoinRequestSerializer
from .permissions import IsAuthenticatedWithProfile
from .authentication import SupabaseAuthentication
import logging
import jwt
from django.conf import settings


logger = logging.getLogger(__name__)       

# ───────── Basic landing ─────────
def myapp(request):
    return render(request, 'main.html')

# Get current user profile
@api_view(['GET'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def get_current_user(request):
    # Get user_id directly from the profile
    user_id = request.user.user_id  # Changed from request.user.username
    
    try:
        # The profile is already available as request.user
        serializer = ProfileSerializer(request.user)
        return Response(serializer.data)
    except Exception as e:
        logger.error(f"Error in get_current_user: {str(e)}")
        return Response({"detail": f"Error: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Profile views
@api_view(['GET'])
def get_profile(request, user_id):
    try:
        profile = Profile.objects.get(user_id=user_id)
        serializer = ProfileSerializer(profile)
        return Response(serializer.data)
    except Profile.DoesNotExist:
        return Response({"detail": "Profile not found"}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def create_profile(request):
    # Get user_id directly from the profile
    user_id = request.user.user_id  # Changed from request.user.username
    
    # Check if profile already exists
    if Profile.objects.filter(user_id=user_id).exists():
        return Response({"detail": "Profile already exists"}, status=status.HTTP_400_BAD_REQUEST)
    
    # Add user_id to request data
    data = request.data.copy()
    data['user_id'] = user_id
    
    # Get email from authenticated profile
    if hasattr(request.user, 'email') and request.user.email:
        data['email'] = request.user.email
    
    serializer = ProfileSerializer(data=data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Modified to handle both PATCH and PUT methods
@api_view(['PATCH', 'PUT'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def update_profile(request, user_id):
    # Verify user is updating their own profile
    token_user_id = request.user.user_id  # Changed from request.user.username
    if token_user_id != user_id:
        return Response({"detail": "Not authorized to update this profile"}, status=status.HTTP_403_FORBIDDEN)
    
    try:
        profile = Profile.objects.get(user_id=user_id)
    except Profile.DoesNotExist:
        return Response({"detail": "Profile not found"}, status=status.HTTP_404_NOT_FOUND)
    
    # Use partial=True for both PATCH and PUT to allow partial updates
    serializer = ProfileSerializer(profile, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Project views
@api_view(['GET'])
@permission_classes([AllowAny])
def get_projects(request):
    search_query = request.query_params.get('query', None)
    
    if search_query:
        # Search in title, content, and user profiles
        projects = Project.objects.filter(
            Q(title__icontains=search_query) | 
            Q(content__icontains=search_query) |
            Q(user_id__in=Profile.objects.filter(
                Q(username__icontains=search_query) | 
                Q(bio__icontains=search_query)
            ).values_list('user_id', flat=True))
        ).order_by('-created_at')
    else:
        projects = Project.objects.all().order_by('-created_at')
    
    # Fix for projects with user_id = 0 or empty
    serializer = ProjectSerializer(projects, many=True)
    data = serializer.data
    for project in data:
        if not project.get('user_id') or project.get('user_id') == '0':
            project['user_id'] = 'unknown'
    
    return Response(data)

@api_view(['POST'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def create_project(request):
    # Get user_id directly from the profile
    user_id = request.user.user_id  # Changed from request.user.username
    
    # Add user_id to request data
    data = request.data.copy()
    data['user_id'] = user_id
    
    serializer = ProjectSerializer(data=data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'DELETE', 'PATCH'])  # Added PATCH
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def project_detail(request, pk):
    try:
        project = Project.objects.get(pk=pk)
    except Project.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    
    # Get user_id directly from the profile
    user_id = request.user.user_id  # Changed from request.user.username
    
    if request.method == 'GET':
        serializer = ProjectSerializer(project)
        return Response(serializer.data)
    
    # Only allow update/delete if user is the creator
    if project.user_id != user_id:
        return Response({"detail": "Not authorized"}, status=status.HTTP_403_FORBIDDEN)
    
    if request.method in ['PUT', 'PATCH']:
        # Use partial=True for PATCH to allow partial updates
        partial = request.method == 'PATCH'
        serializer = ProjectSerializer(project, data=request.data, partial=partial)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        project.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def get_user_projects(request, user_id):
    projects = Project.objects.filter(user_id=user_id).order_by('-created_at')
    serializer = ProjectSerializer(projects, many=True)
    return Response(serializer.data)

# Join Request views
@api_view(['POST'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def create_join_request(request):
    # Get sender_id directly from the profile
    sender_id = request.user.user_id  # Changed from request.user.username
    
    # Get project_id from request
    project_id = request.data.get('project_id')
    if not project_id:
        return Response({"detail": "project_id is required"}, status=status.HTTP_400_BAD_REQUEST)
    
    # Get project to find receiver_id
    try:
        project = Project.objects.get(pk=project_id)
    except Project.DoesNotExist:
        return Response({"detail": "Project not found"}, status=status.HTTP_404_NOT_FOUND)
    
    # Check if user is trying to join their own project
    if project.user_id == sender_id:
        return Response({"detail": "Cannot join your own project"}, status=status.HTTP_400_BAD_REQUEST)
    
    # Check if request already exists
    if JoinRequest.objects.filter(project_id=project_id, sender_id=sender_id).exists():
        return Response({"detail": "Join request already exists"}, status=status.HTTP_400_BAD_REQUEST)
    
    # Create join request
    data = {
        'project_id': project_id,
        'sender_id': sender_id,
        'receiver_id': project.user_id,
        'message': request.data.get('message', ''),
        'status': 'pending'
    }
    
    serializer = JoinRequestSerializer(data=data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['PATCH', 'PUT'])  # Added PUT for compatibility
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def update_join_request_status(request, pk):
    try:
        join_request = JoinRequest.objects.get(pk=pk)
    except JoinRequest.DoesNotExist:
        return Response({"detail": "Join request not found"}, status=status.HTTP_404_NOT_FOUND)
    
    # Get user_id directly from the profile
    user_id = request.user.user_id  # Changed from request.user.username
    
    # Only allow receiver to update status
    if join_request.receiver_id != user_id:
        return Response({"detail": "Not authorized"}, status=status.HTTP_403_FORBIDDEN)
    
    # Update status
    status_value = request.data.get('status')
    if status_value not in ['accepted', 'declined']:
        return Response({"detail": "Invalid status"}, status=status.HTTP_400_BAD_REQUEST)
    
    join_request.status = status_value
    join_request.save()
    
    serializer = JoinRequestSerializer(join_request)
    return Response(serializer.data)

@api_view(['GET'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def get_received_join_requests(request, user_id):
    # Verify user is getting their own requests
    token_user_id = request.user.user_id  # Changed from request.user.username
    if token_user_id != user_id:
        return Response({"detail": "Not authorized"}, status=status.HTTP_403_FORBIDDEN)
    
    join_requests = JoinRequest.objects.filter(receiver_id=user_id).order_by('-created_at')
    serializer = JoinRequestSerializer(join_requests, many=True)
    return Response(serializer.data)

@api_view(['GET'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def get_sent_join_requests(request):
    # Get user_id directly from the profile
    user_id = request.user.user_id  # Changed from request.user.username
    
    join_requests = JoinRequest.objects.filter(sender_id=user_id).order_by('-created_at')
    serializer = JoinRequestSerializer(join_requests, many=True)
    return Response(serializer.data)

@api_view(['GET', 'PATCH', 'PUT'])
@authentication_classes([SupabaseAuthentication])
@permission_classes([IsAuthenticatedWithProfile])
def profile_detail(request, user_id):
    """
    Get or update a profile.
    """
    try:
        profile = Profile.objects.get(user_id=user_id)
    except Profile.DoesNotExist:
        return Response({"detail": "Profile not found"}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = ProfileSerializer(profile)
        return Response(serializer.data)
    
    elif request.method in ['PATCH', 'PUT']:
        # Verify user is updating their own profile
        token_user_id = request.user.user_id
        if token_user_id != user_id:
            return Response({"detail": "Not authorized to update this profile"}, status=status.HTTP_403_FORBIDDEN)
        
        # Use partial=True for both PATCH and PUT to allow partial updates
        serializer = ProfileSerializer(profile, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)