# backend/tests.py

from django.test import TestCase
from rest_framework.test import APIClient, APITestCase
from rest_framework import status
from .models import Profile, Project, JoinRequest
import jwt
from django.conf import settings

class AuthenticationTests(APITestCase):
    """Tests for authentication functionality"""
    
    def setUp(self):
        """Set up test data and clients"""
        self.client = APIClient()
        # Create a test profile
        self.test_profile = Profile.objects.create(
            user_id='test_user_id',
            username='testuser',
            email='test@example.com'
        )
        
        # Create a mock JWT token for testing
        self.test_token = jwt.encode(
            {'sub': 'test_user_id', 'email': 'test@example.com'},
            settings.SUPABASE_JWT_SECRET,
            algorithm='HS256'
        )

    def test_authentication(self):
        """Test that authentication works"""
        response = self.client.get(
            '/me/',
            HTTP_AUTHORIZATION=f'Bearer {self.test_token}'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data['user_id'], 'test_user_id')
        self.assertEqual(data['username'], 'testuser')


class ProfileAPITests(APITestCase):
    """Tests for Profile API endpoints"""
    
    def setUp(self):
        """Set up test data and clients"""
        self.client = APIClient()
        # Create a test profile
        self.test_profile = Profile.objects.create(
            user_id='test_user_id',
            username='testuser',
            email='test@example.com'
        )
        
        # Create a mock JWT token for testing
        self.test_token = jwt.encode(
            {'sub': 'test_user_id', 'email': 'test@example.com'},
            settings.SUPABASE_JWT_SECRET,
            algorithm='HS256'
        )
        
    def test_get_profile(self):
        """Test retrieving a profile"""
        response = self.client.get(
            f'/profile/{self.test_profile.user_id}/',
            HTTP_AUTHORIZATION=f'Bearer {self.test_token}'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data['user_id'], 'test_user_id')
        self.assertEqual(data['username'], 'testuser')
        self.assertEqual(data['email'], 'test@example.com')


class ProjectAPITests(APITestCase):
    """Tests for Project API endpoints"""
    
    def setUp(self):
        """Set up test data and clients"""
        self.client = APIClient()
        # Create a test profile
        self.test_profile = Profile.objects.create(
            user_id='test_user_id',
            username='testuser',
            email='test@example.com'
        )
        
        # Create a test project
        self.test_project = Project.objects.create(
            title='Test Project',
            content='This is a test project',
            user_id='test_user_id'
        )
        
        # Create a mock JWT token for testing
        self.test_token = jwt.encode(
            {'sub': 'test_user_id', 'email': 'test@example.com'},
            settings.SUPABASE_JWT_SECRET,
            algorithm='HS256'
        )
    
    def test_get_projects(self):
        """Test retrieving all projects"""
        response = self.client.get('/homepage/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]['title'], 'Test Project')