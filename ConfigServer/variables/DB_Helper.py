import os
import sys
import pathlib


class Object(object):
    pass;

class DB:
    def __init__(self, path):
        self.path = path

    def get_items(self):
        items = []
        if not os.path.exists(self.path):
            return items
        file = open(self.path, "r")
        lines = file.readlines()
        
        for line in lines:
            if line == "\n":
                continue;
            line = line.replace("export ", "")
            item = Object()
            parameters = line.split("=")
            item.key = parameters[0]
            item.value = parameters[1]
            item.value = item.value.replace('"', '')
            item.value = item.value.replace('\n', '')
            items.append(item)
        file.close()
        return items;

    def convert_item(self, item):
        return 'export ' + item.key + '="' + item.value +'"'


    def append_item(self, item):
        file = open(self.path, "a")
        newline = "\n" + self.convert_item(item)
        file.write(newline)
        file.close()


    def change_item(self, item):
        items = self.get_items()
        open(self.path, "w").close() #delete all file content.
        file_lines = []
        for it in items:
            if it.key == item.key:
                it.value = item.value
            file_lines.append(self.convert_item(it) + "\n")
        file = open(self.path, "w")
        file.writelines(file_lines)
        file.close()

    def remove_item(self, key):
        items = self.get_items()
        file_lines = []
        file = open(self.path, "w").close() #delete all file content.
        for it in items:
            if it.key == key:
                continue;
            file_lines.append(self.convert_item(it)+ "\n")
        file = open(self.path, "w")
        file.writelines(file_lines)
        file.close()

