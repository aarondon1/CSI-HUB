# backend/views.py
from django.shortcuts import render
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Profile, Project
from .serializers import ProfileSerializer, ProjectSerializer

def myapp(request):
    return render(request,'main.html')

# CreateProfile creates a new user profile (POST)
# This view handles the creation of a new user profile. It expects a POST request with the profile data in the request body.
class CreateProfile(APIView):
    def post(self, request):
        serializer = ProfileSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# ProfileView fetches a user profile by user_id (GET)
# This view retrieves a user profile based on the provided user_id. It expects a GET request with the user_id in the URL.
class ProfileView(APIView):
    def get(self, request, user_id):
        try:
            profile = Profile.objects.get(user_id=user_id)
            serializer = ProfileSerializer(profile)
            return Response(serializer.data)
        except Profile.DoesNotExist:
            return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)
        
# CreateProject creates a new project (POST)
# This view handles the creation of a new project. It expects a POST request with the project data in the request body.
class CreateProject(APIView):
    def post(self, request):
        user_id = request.data.get('user_id')
        try:
            #checks if the user exists
            profile = Profile.objects.get(user_id=user_id)
        except Profile.DoesNotExist:
            return Response({'error': 'Profile not found'}, status=status.HTTP_404_NOT_FOUND)
        # Copy the request data and associate the project with the user's profile
        data = request.data.copy()
        data['user'] = profile.id # sets the "user" field to the profile's ID

        serializer = ProjectSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# HomePageView fetches all projects (GET)
# This view retrieves all projects and allows for optional filtering based on a query parameter.
class HomePageView(APIView):
    def get(self, request):
        # optional query param, if the query parameter is not provided it defaults to an empty string
        # for exmaple if the query = "Dolphin" it will return all projects with "Dolphin" in the title
        query = request.GET.get('query', '') 
        # fetches all the projects from the database
        projects = Project.objects.all()

        if query:
            projects = projects.filter(title__icontains=query)

        serializer = ProjectSerializer(projects, many=True)
        return Response(serializer.data)

# UserProjectsView fetches projects for a specific user (GET)
# This view retrieves all projects associated with a specific user based on the user_id provided in the URL.
class UserProjectsView(APIView):
    def get(self, request, user_id):
        projects = Project.objects.filter(user__user_id=user_id)
        serializer = ProjectSerializer(projects, many=True)
        return Response(serializer.data)

