from django.urls import path
from . import views

urlpatterns = [
    path('', views.myapp),
    path('create-profile/', views.CreateProfile.as_view()),
    path('profile/<str:user_id>/', views.ProfileView.as_view()),
    path('create-project/', views.CreateProject.as_view()),
    path('homepage/', views.HomePageView.as_view()),
    path('user-projects/<str:user_id>/', views.UserProjectsView.as_view()),
    path('join-request/', views.CreateJoinRequest.as_view()),
    path('join-request/<str:user_id>/',views.ReceivedJoinRequests.as_view()),
    path('join-request/<int:request_id>/status/', views.UpdateJoinRequestStatus.as_view()),
]   