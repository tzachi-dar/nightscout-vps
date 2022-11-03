import os

from django.shortcuts import render, redirect
from django.http import HttpResponse, HttpResponseRedirect
from django.template import loader
from django.urls import reverse
import json
from variables.DB_Helper import DB, Object
from  variables import apps

# Make sure to test this var before each request !!!
ENV_TOKEN = os.environ.get('ENV_TOKEN')
if not ENV_TOKEN:
    print("system must load with ENV_TOKEN. use \"export ENV_TOKEN=security token\" before starting")
    os._exit(1)

NS_CONFIG_FILE = os.environ.get('NS_CONFIG_FILE')
if not NS_CONFIG_FILE:
    print("system must load with NS_CONFIG_FILE. use \"export NS_CONFIG_FILE=/path/to/file\" before starting")
    os._exit(1)
db = DB(NS_CONFIG_FILE)


def index(request):
    print("In index",type(request), request, request.GET.get('token',''), "session=" + request.session.get('token', 'mini'))
    apps.kiling_timer.ServerInUse()
    token = request.GET.get('token',request.session.get('token', ''))
    template = loader.get_template('table.html')
    if token != ENV_TOKEN:
        context = {}
        template = loader.get_template('badkey.html')
        return HttpResponse(template.render(context, request))
    # Set a session value
    request.session['token'] = token
    items = db.get_items()
    context = {
    'variables': items,
    }
    return HttpResponse(template.render(context, request))



def addrecord(request):
    print("In add record",type(request), request, request.POST.get('token',''), request.session.get('token', 'mini'))
    print("In add record 2", request.session.get('token', 'mini'))
    apps.kiling_timer.ServerInUse()
    token = request.session.get('token', '')
    if token != ENV_TOKEN:
        context = {}
        template = loader.get_template('badkey.html')
        return HttpResponse(template.render(context, request))
    obj = Object(request.POST['key'], request.POST['value'])
    db.append_item(obj)
    return HttpResponseRedirect(reverse('index'))

def removerecord(request):
    apps.kiling_timer.ServerInUse()
    token = request.session.get('token', '')
    if token != ENV_TOKEN:
        context = {}
        template = loader.get_template('badkey.html')
        return HttpResponse(template.render(context, request))

    key = request.POST['key']
    db.remove_item(key)
    return HttpResponseRedirect(reverse('index'))

def changerecord(request):
    apps.kiling_timer.ServerInUse()
    print("change Called")
    token = request.session.get('token', '')
    if token != ENV_TOKEN:
        context = {}
        template = loader.get_template('badkey.html')
        return HttpResponse(template.render(context, request))

    data = json.loads(request.body.decode('utf-8'))
    item = Object(data['key'], data['new_content'])
    db.change_item(item)
    return HttpResponseRedirect(reverse('index'))

