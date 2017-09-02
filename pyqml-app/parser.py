#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import PyQt5
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot

# class for handling signals of qml-scene, filling the table and filtering it's content
class Parser(QObject):
    def __init__(self):
        QObject.__init__(self)


if __name__ == '__main__':
    sys_argv = sys.argv
    sys_argv += ['--style', 'material'] # gratifying to the eye
    app = QGuiApplication(sys_argv)
    engine = QQmlApplicationEngine()
    parser = Parser()
    engine.rootContext().setContextProperty("parser", parser)
    engine.load("parse-gui.qml")
    engine.quit.connect(app.quit)
    sys.exit(app.exec_())
