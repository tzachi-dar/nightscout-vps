from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('addrecord/', views.addrecord, name='addrecord'),
    path('removerecord/', views.removerecord, name='removerecord'),
    path('changerecord/', views.changerecord, name='changerecord'),


]
