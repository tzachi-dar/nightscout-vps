from django.apps import AppConfig
import time, threading
import os

# A class to kill the server after some time of inactivity.
class KillingTimer:
    def __init__(self):
        self.last_use_time = time.time()

    def timer(self):
        print(time.ctime())
        if time.time() - self.last_use_time > 10:
            print('killing processes because of inactivity')
            os._exit(6)
        threading.Timer(1, self.timer).start()
        
    def ServerInUse(self):
        print("ServerInUse called")
        self.last_use_time = time.time()
        

kiling_timer = KillingTimer()

class MembersConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'variables'

    def ready(self):
        kiling_timer.timer()