from django.urls import path
from . import views

urlpatterns = [
    path('', views.myapp),

    # Profiles
    path('create-profile/', views.CreateProfile.as_view()),
    path('profile/<str:user_id>/', views.ProfileView.as_view()),
    path('me/', views.MeView.as_view()),

    # Projects
    path('create-project/', views.CreateProject.as_view()),       # POST
    path('projects/<int:project_id>/', views.ProjectDetail.as_view()),  # DELETE
    path('user-projects/<str:user_id>/', views.UserProjectsView.as_view()),
    path('homepage/', views.HomePageView.as_view()),              # GET with ?query=

    # Join-requests 
    path('join-request/<int:request_id>/status/', views.UpdateJoinRequestStatus.as_view()),
    path('join-request/', views.CreateJoinRequest.as_view()),     # POST
    path('join-request/user/<str:user_id>/', views.ReceivedJoinRequests.as_view()),
    path('join-request/sent/', views.SentJoinRequests.as_view()),
]
