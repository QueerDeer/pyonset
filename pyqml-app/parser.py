#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
import asyncio
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot


# class for handling signals of qml-scene, filling the table and filtering it's content by saved dict-list
class Parser(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.filedict = []  # rows of ordered dicts for filtering
        self.savedfilename = ''  # stuff for clearing filter's stack

    rowAdd = pyqtSignal(int, arguments=['mesg'])  # add new row through context param-s
    setUp = pyqtSignal(int, arguments=['mesg'])  # add first
    updatePeriod = pyqtSignal(str, str, arguments=['mesg1', 'mesg2'])   # add default limits

    # initiate updating of tableview model into qml-scene throwing data through context
    def throwdata(self, row):
        list_model_1 = row['timestamp']
        list_model_2 = row['msgtype']
        list_model_3 = row['sigsource']
        list_model_4 = row['msgcontent']
        root_context.setContextProperty('model1', list_model_1)
        root_context.setContextProperty('model2', list_model_2)
        root_context.setContextProperty('model3', list_model_3)
        root_context.setContextProperty('model4', list_model_4)
        self.rowAdd.emit(1)

    # calling by openfile (following async couple are for acc.filtering)
    async def filetotable(self):
        for row in self.filedict:
            self.throwdata(row)

    # calling by type-source filter
    async def tysototable(self, msgtype, fieldtype):
            buferdictlist = []
            for row in self.filedict:
                if row[fieldtype] == msgtype:
                    self.throwdata(row)
                    buferdictlist.append(row)
            self.filedict = list(buferdictlist)

    # calling by timestamp filter
    async def periodtotable(self, first, last):
            buferdictlist = []
            for row in self.filedict:
                if first <= row['timestamp'] <= last:
                    self.throwdata(row)
                    buferdictlist.append(row)
            self.filedict = list(buferdictlist)

    # filling table with row of timestamp limits in first and last param-s
    @pyqtSlot(str, str)
    def filterbytime(self, first, last):
        self.setUp.emit(1)
        loop = asyncio.get_event_loop()
        loop.run_until_complete(self.periodtotable(first, last))

    # filling table with rows of special single words in their concrete fields (such as 'msgtype', 'sigsource')
    @pyqtSlot(str, str)
    def filterbytypesource(self, msgtype, fieldtype):
        self.setUp.emit(1)
        if msgtype == '':
            self.openfile(self.savedfilename)
        else:
            loop = asyncio.get_event_loop()
            loop.run_until_complete(self.tysototable(msgtype, fieldtype))

    # open file by piece of it's fullpath to write it in a dict for filtering and rebuild tableview's model
    @pyqtSlot(str)
    def openfile(self, filename):
        with open(filename[7:]) as csvfile:
            self.savedfilename = filename
            self.setUp.emit(1)
            reader = csv.DictReader(csvfile,  fieldnames=['timestamp', 'msgtype', 'sigsource', 'msgcontent'],
                                    dialect='excel-tab')
            self.filedict = list(reader)
            self.updatePeriod.emit(self.filedict[1]['timestamp'], self.filedict[-1]['timestamp'])
            loop = asyncio.get_event_loop()
            loop.run_until_complete(self.filetotable())

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
