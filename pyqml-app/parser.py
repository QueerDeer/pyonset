#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, QSortFilterProxyModel  # maybe this, mabe py's dict's feat.


# class for handling signals of qml-scene, filling the table and filtering it's content
class Parser(QObject):
    def __init__(self, root_context):
        QObject.__init__(self)
        self.root_context = root_context

    rowAdd = pyqtSignal(int, arguments=['mesg'])  # add new row through context param-s
    setUp = pyqtSignal(int, arguments=['mesg'])  # add first

# open file by piece of it's fullpath and rebuild tableview's model
    @pyqtSlot(str)
    def openfile(self, filename):
        with open(filename[7:]) as csvfile:
            self.setUp.emit(1)
            reader = csv.DictReader(csvfile,  fieldnames=['timestamp', 'msgtype', 'sigsource', 'msgcontent'], dialect='excel-tab')
            for row in reader:
                list_model_1 = row['timestamp']
                list_model_2 = row['msgtype']
                list_model_3 = row['sigsource']
                list_model_4 = row['msgcontent']
                root_context.setContextProperty('model1', list_model_1)
                root_context.setContextProperty('model2', list_model_2)
                root_context.setContextProperty('model3', list_model_3)
                root_context.setContextProperty('model4', list_model_4)
                self.rowAdd.emit(1)
            csvfile.close()
            del reader  # temp


if __name__ == '__main__':
    sys_argv = sys.argv
    sys_argv += ['--style', 'material']  # gratifying to the eye
    app = QGuiApplication(sys_argv)
    engine = QQmlApplicationEngine()
    root_context = engine.rootContext()
    parser = Parser(root_context)
    root_context.setContextProperty("parser", parser)
    engine.load("parse-gui.qml")
    engine.quit.connect(app.quit)
    sys.exit(app.exec_())
