import os
import sys
import pathlib
import re
from json import loads


class Object(object):
    def __init__(self, key, value, description="", default=""):
        self.key = key
        self.value = value
        self.description = description
        self.default = default

    def __str__(self):
        return "Key " + self.key + " value " + self.value + "desc " + self.description + "default " + self.default


class DB:
    def __init__(self, path):
        self.path = path
        self.possible_items = []

    def parse_line(line):
        line = line.replace("export ", "")
        params = line.split("=")
        try:
            key = params[0]
            value = params[1].replace('"', '')
        except:
            return None
        return Object(key, value)

        match = re.match("export *(.*)=[\"'](.*)[\"']", line)
        if match:
            return Object(match.group(1), match.group(2))
        else:
            match = re.match("export *(.*)=(.*)", line)
            if match:
                return Object(match.group(1), match.group(2))
        return None

    def get_possible_items(self):
        return self.possible_items


    def get_items(self):
        items = []
        new_items = []
        requireds = []
        self.possible_items = []
        if not os.path.exists(self.path):
            return items
        file = open(self.path, "r+")
        lines = file.read().split("export")  # can not read two-line value correctly.
        del lines[0]
        file.close()
        file = open(r"..\app.json", "r")
        js = file.read()
        file.close()
        js = loads(js)["env"]
        for line in lines:
            line = line.strip()
            item = DB.parse_line("export " + line)
            if line == "":
                continue;
            if not item:
                print("Something went wrong. couldn't parse", line)
                continue;
            if item.key in js:
                item.description = js[item.key]["description"]
                item.default = js[item.key]["value"]
                item.required = js[item.key]["required"]
                del js[item.key]
                if item.required == "true":
                    requireds.append(item)
                else:
                    items.append(item)
            else:
                item.description = "Key was not used before."
                new_items.append(item)

        items = requireds + items + new_items  # so new keys would appear in the end of the table
        for key in js:
            item = Object(key, "", js[key]["description"], js[key]["value"])
            self.possible_items.append(item)
        return items;

    def convert_item(self, item):
        return str('export ' + item.key + '="' + str(item.value.replace("\r", "")) + '"')

    def append_item(self, item):
        file = open(self.path, "a")
        newline = "\n" + self.convert_item(item)
        file.write(newline)
        file.close()

    def change_item(self, item):
        items = self.get_items()
        open(self.path, "w").close()  # delete all file content.
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
        open(self.path, "w").close()  # delete all file content.
        for it in items:
            if it.key == key:
                continue;
            file_lines.append(self.convert_item(it) + "\n")
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
    test_line('export xxx=1', "xxx", "1")
    test_line('export xxx="1 2"', "xxx", "1 2")
    test_line('export xxx=1 2', "xxx", "1 2")
    test_line('export xxx="1 \"2"', "xxx", "1 \"2")
    test_line('export xxx="1 \'*\'2"', "xxx", "1 '*'2")
    # does not work test_line('export xxx="1 "*"2"', "xxx", "1")
    test_line("export xxx='1'", "xxx", "1")
    test_line("export xxx='1 \"2'", "xxx", "1 \"2")


if __name__ == "__main__":
    test_re()
