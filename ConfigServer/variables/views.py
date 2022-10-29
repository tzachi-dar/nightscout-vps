from django.shortcuts import render, redirect
from django.http import HttpResponse, HttpResponseRedirect
from django.template import loader
from django.urls import reverse
import json
from variables.DB_Helper import DB, Object

db = DB(r"example.txt")


def index(request):
    template = loader.get_template('table.html')
    items = db.get_items()
    context = {
    'variables': items,
    }
    return HttpResponse(template.render(context, request))


def addrecord(request):
    obj = Object()
    obj.key = request.POST['key']
    obj.value = request.POST['value']
    db.append_item(obj)
    return HttpResponseRedirect(reverse('index'))

def removerecord(request):
    key = request.POST['key']
    db.remove_item(key)
    return HttpResponseRedirect(reverse('index'))

def changerecord(request):
    print("change Called")
    data = json.loads(request.body.decode('utf-8'))
    item = Object()
    item.key = data['key']
    item.value = data['new_content']
    db.change_item(item)
    return HttpResponseRedirect(reverse('index'))

