#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
# from PyQt5 import QtGui
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot


# class for handling signals of qml-scene, filling the table and filtering it's content
class Parser(QObject):
    def __init__(self):
        QObject.__init__(self)

    @pyqtSlot()
    def openfile(self):
        # filename = QtGui.QFileDialog.getOpenFileName(self, 'Open File', '.csv') - no widgets, go to QtQuick.Dialogs.
        filename = 'test.csv'
        with open(filename) as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                print(row['first_name'], row['last_name'])


if __name__ == '__main__':
    sys_argv = sys.argv
    sys_argv += ['--style', 'material']  # gratifying to the eye
    app = QGuiApplication(sys_argv)
    engine = QQmlApplicationEngine()
    parser = Parser()
    engine.rootContext().setContextProperty("parser", parser)
    engine.load("parse-gui.qml")
    engine.quit.connect(app.quit)
    sys.exit(app.exec_())
