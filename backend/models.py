from django.db import models

class Profile(models.Model):
    user_id = models.CharField(max_length=255, unique=True) # Supabase UID
    username = models.CharField(max_length=255)
    bio = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    

class Project(models.Model):
    user = models.ForeignKey(Profile, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    

class JoinRequest(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE)
    sender = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='sent_requests')
    receiver = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='received_requests')
    message = models.TextField(blank=True)
    status = models.CharField(default='pending', choices=[
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('declined', 'Declined')
    ], max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)
