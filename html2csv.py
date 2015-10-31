from HTMLParser import HTMLParser
import sys
import re


class HTMLTableParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.despace_re = re.compile(r'\s+')
        self.data_interrupt = False
        self.first_row = True
        self.first_cell = True
        self.in_cell = False

    def handle_starttag(self, tag, attrs):
        self.data_interrupt = True
        if tag == "table":
            self.first_row = True
            self.first_cell = True
        elif tag == "tr":
            if not self.first_row:
                sys.stdout.write("\n")
            self.first_row = False
            self.first_cell = True
            self.data_interrupt = False
        elif tag == "td" or tag == "th":
            if not self.first_cell:
                sys.stdout.write("|")
            self.first_cell = False
            self.data_interrupt = False
            self.in_cell = True

    def handle_endtag(self, tag):
        self.data_interrupt = True
        if tag == "td" or tag == "th":
            self.in_cell = False

    def handle_data(self, data):
        if self.in_cell:
            #if self.data_interrupt:
            #   sys.stdout.write(" ")
            sys.stdout.write(self.despace_re.sub(' ', data).strip())
            self.data_interrupt = False

parser = HTMLTableParser()
from sys import argv
script, filename = argv
txt_again = open(filename)
parser.feed(txt_again.read())
txt_again.close()