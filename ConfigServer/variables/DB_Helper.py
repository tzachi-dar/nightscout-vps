import os
import sys
import pathlib
import re


class Object(object):
    def __init__(self, key, value):
        self.key = key
        self.value = value


class DB:
    def __init__(self, path):
        self.path = path

    def parse_line(line):
        match = re.match("export *(.*)=[\"'](.*)[\"']", line)
        if match:
            return Object(match.group(1), match.group(2))
        else: 
            match = re.match("export *(.*)=(.*)", line)
            if match:
                return Object(match.group(1), match.group(2))
        return None


    def get_items(self):
        items = []
        if not os.path.exists(self.path):
            return items
        file = open(self.path, "r")
        lines = file.readlines()
        
        for line in lines:
            line = line.strip()
            item = DB.parse_line(line)
            if item:
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

def test_line(line, expected_key, expected_val):
   out = DB.parse_line(line)
   if out.key != expected_key or out.value != expected_val:
       print("test failed for line", line, "out.key=", out.key, "out.value=", out.value)

def test_re():
    print("testint")
    test_line('export xxx="1"', "xxx", "1")
    test_line('export xxx=1'  , "xxx", "1")
    test_line('export xxx="1 2"', "xxx", "1 2")
    test_line('export xxx=1 2', "xxx", "1 2")
    test_line('export xxx="1 \"2"', "xxx", "1 \"2")
    test_line('export xxx="1 \'*\'2"', "xxx", "1 '*'2")
    # does not work test_line('export xxx="1 "*"2"', "xxx", "1")
    test_line("export xxx='1'", "xxx", "1")
    test_line("export xxx='1 \"2'", "xxx", "1 \"2")

if __name__ == "__main__":
   test_re()