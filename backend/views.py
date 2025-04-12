#request handler
from django.shortcuts import render

#this renders the main page of the app
def myapp(request):
    return render(request, 'main.html')
