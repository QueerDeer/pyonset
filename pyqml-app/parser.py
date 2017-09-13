#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
import json
from multiprocessing import Pool # ThreadPool and imap?
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, QSysInfo


# class for handling signals of qml-scene, filling the table and filtering it's content by saved dict-list
class Parser(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.filedict = []  # rows of ordered dicts from the log (for ordered filtering)
        self.savedfilename = ''  # stuff for clearing filter's stack

    rowAdd = pyqtSignal(int, arguments=['mesg'])  # add new row through context param-s
    setUp = pyqtSignal(int, arguments=['mesg'])  # add first
    updatePeriod = pyqtSignal(str, str, arguments=['mesg1', 'mesg2'])   # add default limits

    # initiate updating of tableview model into qml-scene throwing data through context
    def throwdata(self, row):
        root_context.setContextProperty('model1', row['timestamp'])
        root_context.setContextProperty('model2', row['msgtype'])
        root_context.setContextProperty('model3', row['sigsource'])
        root_context.setContextProperty('model4', row['msgcontent'])
        self.rowAdd.emit(1)

    # calling by openfile and in the end of ordered filter (following couple are for filtering)
    def filetotable(self):
        for index, row in enumerate(self.filedict):
            self.throwdata(row)
            if not index % 5000:  # period was spinned out of thin air
                QGuiApplication.processEvents()

    # filling bufferdict with rows of special single words in their concrete fields (such as 'msgtype', 'sigsource')
    def tysototable(self, msgtype, fieldtype):
            buferdictlist = []
            for index, row in enumerate(self.filedict):
                if row[fieldtype] in msgtype:
                    buferdictlist.append(row)
            self.filedict = list(buferdictlist)

    # filling bufferdict with row of timestamp limits in first and last param-s
    def periodtotable(self, first, last):
            buferdictlist = []
            for index, row in enumerate(self.filedict):
                if first <= row['timestamp'] <= last:
                    buferdictlist.append(row)
            self.filedict = list(buferdictlist)

    # open file by piece of it's fullpath to write it in a dict for filtering and rebuild tableview's model
    @pyqtSlot(str)
    def openfile(self, filename):
        if QSysInfo.productType() == 'windows':
            fullpath = filename[8:]
        else:
            fullpath = filename[7:]
        with open(fullpath) as csvfile:
            self.savedfilename = fullpath
            self.setUp.emit(1)
            reader = csv.DictReader(csvfile,
                                    fieldnames=['timestamp', 'msgtype', 'sigsource', 'msgcontent'],
                                    dialect='excel-tab')
            self.filedict = list(reader)
            self.updatePeriod.emit(self.filedict[1]['timestamp'], self.filedict[-1]['timestamp'])
            self.filetotable()

    # ordered filtering and pushing buffer to table
    @pyqtSlot(str, str, str, str)
    def queuedfilter(self, first, last, typelist, sourcelist):
        self.setUp.emit(1)

        self.periodtotable(first, last)
        self.tysototable(json.loads(typelist), 'msgtype')
        self.tysototable(json.loads(sourcelist), 'sigsource')
        self.filetotable()

        # and reset accumulation of ordered group filter
        reader = csv.DictReader(open(self.savedfilename),
                                fieldnames=['timestamp', 'msgtype', 'sigsource', 'msgcontent'],
                                dialect='excel-tab')
        self.filedict = list(reader)


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
