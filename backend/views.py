# backend/views.py
from django.shortcuts import render
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Profile, Project, JoinRequest
from .serializers import ProfileSerializer, ProjectSerializer, JoinRequestSerializer

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
        
    # UpdateProfile updates a user profile (PATCH)
    # This view handles the partial update of a user profile. It expects a PATCH request with the updated data in the request body.
    def patch(self, request, user_id):
        # Fetch the profile based on the user_id provided in the URL
        # and update the profile with the data provided in the request body.
        try:
            profile = Profile.objects.get(user_id=user_id)
        except Profile.DoesNotExist:
            return Response({'error': 'Profile not found'}, status=404)
        # Use the ProfileSerializer to validate and update the profile data
        serializer = ProfileSerializer(profile, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)
        
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
    
    
# CreateJoinRequest creates a join request (POST)
# This view handles the creation of a join request for a project. It expects a POST request with the join request data in the request body. 
class CreateJoinRequest(APIView):
    # It expects a POST request with the sender_id, project_id, and an optional message in the request body.
    def post(self, request):
        sender_id = request.data.get('sender_id')
        project_id = request.data.get('project_id')
        message = request.data.get('message', '')
        # checks if the sender and project exist
        # and retrieves the sender's profile and the project owner.
         # If either the sender or project does not exist, it returns a 400 error response.
        # Validate sender
        try:
            sender = Profile.objects.get(user_id=sender_id)
        except Profile.DoesNotExist:
            return Response({'error': 'Invalid sender or project'}, status=status.HTTP_400_BAD_REQUEST)

        # Validate project
        try:
            project = Project.objects.get(id=project_id)
        except Project.DoesNotExist:
            return Response({'error': 'Invalid sender or project'}, status=status.HTTP_400_BAD_REQUEST)

        # Create the join request
        join_request = JoinRequest.objects.create(
            sender=sender,
            project=project,
            receiver=project.user,  # Assuming the project owner is the receiver
            message=message
        )
        serializer = JoinRequestSerializer(join_request)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
# ReceivedJoinRequests fetches all join requests received by a user (GET)
# This view retrieves all join requests received by a specific user based on the user_id provided in the URL.
class ReceivedJoinRequests(APIView):
    # It expects a GET request with the user_id in the URL.
    def get(self, request, user_id):
        try:
            profile = Profile.objects.get(user_id=user_id)
        except Profile.DoesNotExist:
            return Response({'error': 'User not found'}, status=404)

        requests = JoinRequest.objects.filter(receiver=profile)
        serializer = JoinRequestSerializer(requests, many=True)
        return Response(serializer.data)
    
# UpdateJoinRequestStatus updates the status of a join request (PATCH)
# This view handles the update of a join request's status. It expects a PATCH request with the status in the request body.
class UpdateJoinRequestStatus(APIView):
    def patch(self, request, request_id):
        try:
            join_request = JoinRequest.objects.get(id=request_id)
        except JoinRequest.DoesNotExist:
            return Response({'error': 'Not found'}, status=404)

        status = request.data.get('status')
        if status not in ['accepted', 'declined']:
            return Response({'error': 'Invalid status'}, status=400)

        join_request.status = status
        join_request.save()
        return Response({'status': 'updated'})


    
    


