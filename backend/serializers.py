from rest_framework import serializers
from .models import Profile, Project

# This file contains the serializers for the Profile and Project models.

# the serializers are used to convert complex data types, such as querysets and model instances, 
# into native Python datatypes that can then be easily rendered into JSON, XML or other content types.

# The ProfileSerializer is used to serialize the Profile model, which contains user profile information.
class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = '__all__'
        
# The ProjectSerializer is used to serialize the Project model, which contains Project Project information.        
class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = '__all__'
