from django.shortcuts import render
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Profile, Project, JoinRequest
from .serializers import ProfileSerializer, ProjectSerializer, JoinRequestSerializer
from .authentication import authentication_required

# ───────── Basic landing ─────────
def myapp(request):
    return render(request, 'main.html')

# ───────── Profiles ─────────
class CreateProfile(APIView):
    @authentication_required
    def post(self, request):
        user_id = request.user_info['sub']
        email   = request.user_info.get('email', '')
        if Profile.objects.filter(user_id=user_id).exists():
            return Response({'error': 'Profile already exists'}, status=400)

        profile = Profile.objects.create(
            user_id=user_id,
            email=email,
            username=request.data.get('username', email.split('@')[0]),
            bio=request.data.get('bio', '')
        )
        return Response(ProfileSerializer(profile).data, status=201)


class ProfileView(APIView):
    @authentication_required
    def get(self, request, user_id):
        try:
            profile = Profile.objects.get(user_id=user_id)
            return Response(ProfileSerializer(profile).data)
        except Profile.DoesNotExist:
            return Response({'error': 'Profile not found'}, status=404)

    @authentication_required
    def patch(self, request, user_id):
        try:
            profile = Profile.objects.get(user_id=user_id)
        except Profile.DoesNotExist:
            return Response({'error': 'Profile not found'}, status=404)

        serializer = ProfileSerializer(profile, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)


class MeView(APIView):
    @authentication_required
    def get(self, request):
        return Response(ProfileSerializer(request.profile).data)

# ───────── Projects ─────────
class CreateProject(APIView):
    @authentication_required
    def post(self, request):
        project = Project.objects.create(
            user=request.profile,
            title=request.data.get('title'),
            content=request.data.get('content')
        )
        return Response(ProjectSerializer(project).data, status=201)


class ProjectDetail(APIView):
    """
    DELETE /projects/<id>/  owner can delete their own project
    """
    @authentication_required
    def delete(self, request, project_id):
        try:
            project = Project.objects.get(id=project_id, user=request.profile)
        except Project.DoesNotExist:
            return Response({'error': 'Not found'}, status=404)
        project.delete()
        return Response(status=204)


class HomePageView(APIView):
    @authentication_required
    def get(self, request):
        query = request.GET.get('query', '')
        projects = Project.objects.all()
        if query:
            projects = projects.filter(title__icontains=query)
        return Response(ProjectSerializer(projects, many=True).data)


class UserProjectsView(APIView):
    @authentication_required
    def get(self, request, user_id):
        projects = Project.objects.filter(user__user_id=user_id)
        return Response(ProjectSerializer(projects, many=True).data)

# ───────── Join-requests ─────────
class CreateJoinRequest(APIView):
    @authentication_required
    def post(self, request):
        sender = request.profile
        project_id = request.data.get('project_id')
        message = request.data.get('message', '')

        try:
            project = Project.objects.get(id=project_id)
        except Project.DoesNotExist:
            return Response({'error': 'Project not found'}, status=400)

        join_request = JoinRequest.objects.create(
            sender=sender,
            project=project,
            receiver=project.user,   # project owner
            message=message
        )
        return Response(JoinRequestSerializer(join_request).data, status=201)


class ReceivedJoinRequests(APIView):
    @authentication_required
    def get(self, request, user_id):
        try:
            profile = Profile.objects.get(user_id=user_id)
        except Profile.DoesNotExist:
            return Response({'error': 'User not found'}, status=404)

        requests = JoinRequest.objects.filter(receiver=profile)
        return Response(JoinRequestSerializer(requests, many=True).data)


class SentJoinRequests(APIView):
    """GET /join-request/sent/  requests *I* have sent"""
    @authentication_required
    def get(self, request):
        requests = JoinRequest.objects.filter(sender=request.profile)
        return Response(JoinRequestSerializer(requests, many=True).data)


class UpdateJoinRequestStatus(APIView):
    @authentication_required
    def patch(self, request, request_id):
        try:
            join_request = JoinRequest.objects.get(id=request_id, receiver=request.profile)
        except JoinRequest.DoesNotExist:
            return Response({'error': 'Join Request not found'}, status=404)

        status_value = request.data.get('status')
        if status_value not in ('accepted', 'declined'):
            return Response({'error': 'Invalid status'}, status=400)

        join_request.status = status_value
        join_request.save()
        return Response({'status': 'updated'})
