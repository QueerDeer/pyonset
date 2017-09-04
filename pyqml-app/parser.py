#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot  # there are still no need in signals, maybe it will change soon


# class for handling signals of qml-scene, filling the table and filtering it's content
class Parser(QObject):
    def __init__(self, root_context):
        QObject.__init__(self)
        self.root_context = root_context

# open file by piece of it's fullpath and rebuild tableview's model
    @pyqtSlot(str)
    def openfile(self, filename):
        with open(filename[7:]) as csvfile:
            list_model = []
            reader = csv.DictReader(csvfile)
            # listmodel should be transform into my own QAbstractTableModel for the right content order, now it's wrong
            for row in reader:
                list_model += (row['msgtype'], row['signtext'], row['onenumb'], row['anothernumb'])
            root_context.setContextProperty('listModel', list_model)


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
