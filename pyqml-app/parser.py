#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot


# class for handling signals of qml-scene, filling the table and filtering it's content by saved dict-list
class Parser(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.filedict = []
        self.savedfilename = ''

    rowAdd = pyqtSignal(int, arguments=['mesg'])  # add new row through context param-s
    setUp = pyqtSignal(int, arguments=['mesg'])  # add first
    updatePeriod = pyqtSignal(str, str, arguments=['mesg1', 'mesg2'])   # add default limits

    # initiate updating of tableview model into qml-scene throwing data through context
    def rowtotable(self, row):
        list_model_1 = row['timestamp']
        list_model_2 = row['msgtype']
        list_model_3 = row['sigsource']
        list_model_4 = row['msgcontent']
        root_context.setContextProperty('model1', list_model_1)
        root_context.setContextProperty('model2', list_model_2)
        root_context.setContextProperty('model3', list_model_3)
        root_context.setContextProperty('model4', list_model_4)
        self.rowAdd.emit(1)

    # filling table with row of timestamp limits in first and last param-s
    @pyqtSlot(str, str)
    def filterbytime(self, first, last):
        self.setUp.emit(1)
        buferdictlist = []
        for row in self.filedict:
            if first <= row['timestamp'] <= last:
                self.rowtotable(row)
                buferdictlist.append(row)
        self.filedict = list(buferdictlist)

    # filling table with rows of special single words in their concrete fields (such as 'msgtype', 'sigsource')
    @pyqtSlot(str, str)
    def filterbytypesource(self, msgtype, fieldtype):
        self.setUp.emit(1)
        if msgtype == '':
            self.openfile(self.savedfilename)
        else:
            buferdictlist = []
            for row in self.filedict:
                if row[fieldtype] == msgtype:
                    self.rowtotable(row)
                    buferdictlist.append(row)
            self.filedict = list(buferdictlist)

    # open file by piece of it's fullpath to write it in a dict for filtering, repeat it to rebuild tableview's model
    # or it will close immediately and will not be accessible for iterating
    @pyqtSlot(str)
    def openfile(self, filename):
        with open(filename[7:]) as csvfile:
            self.savedfilename = filename
            self.setUp.emit(1)
            reader = csv.DictReader(csvfile,  fieldnames=['timestamp', 'msgtype', 'sigsource', 'msgcontent'], dialect='excel-tab')
            self.filedict = list(reader)
            self.updatePeriod.emit(self.filedict[1]['timestamp'], self.filedict[-1]['timestamp'])
            with open(filename[7:]) as csvfile:
                reader = csv.DictReader(csvfile,  fieldnames=['timestamp', 'msgtype', 'sigsource', 'msgcontent'], dialect='excel-tab')
                for row in reader:
                    self.rowtotable(row)

if __name__ == '__main__':
    sys_argv = sys.argv
    sys_argv += ['--style', 'material']  # gratifying to the eye
    app = QGuiApplication(sys_argv)
    engine = QQmlApplicationEngine()
    root_context = engine.rootContext()
    parser = Parser()
    root_context.setContextProperty("parser", parser)
    engine.load("parse-gui.qml")
    engine.quit.connect(app.quit)
    sys.exit(app.exec_())
