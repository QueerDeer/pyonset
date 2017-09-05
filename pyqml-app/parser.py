#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
from PyQt5.QtGui import QGuiApplication, QStandardItemModel, QStandardItem
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, QByteArray, Qt


# class for handling signals of qml-scene, filling the table and filtering it's content
class Parser(QObject):
    def __init__(self, root_context):
        QObject.__init__(self)
        self.root_context = root_context

    rowAdd = pyqtSignal(int, arguments=['mesg'])

# open file by piece of it's fullpath and rebuild tableview's model
    @pyqtSlot(str)
    def openfile(self, filename):
        with open(filename[7:]) as csvfile:
#            model = QStandardItemModel()
#            model.setColumnCount(4)
#            headerNames = []
#            headerNames.append("msgtype")
#            headerNames.append("signtext")
#            headerNames.append("onenumb")
#            headerNames.append("anothernumb")
#            model.setHorizontalHeaderLabels(headerNames)
#            table_row = []
#            QAbstractTableModel overriding and QStandartItemModel using doesn't work with QML ?("fresh" bug, damn day,
#            damn private properties of core classes X D)

            reader = csv.DictReader(csvfile)  # there should be new true dialect for real log-file
            for row in reader:
                list_model_1 = row['msgtype']
                list_model_2 = row['signtext']
                list_model_3 = row['onenumb']
                list_model_4 = row['anothernumb']
                root_context.setContextProperty('model1', list_model_1)
                root_context.setContextProperty('model2', list_model_2)
                root_context.setContextProperty('model3', list_model_3)
                root_context.setContextProperty('model4', list_model_4)
                self.rowAdd.emit(1)

#                for name in list_model:
#                    item = QStandardItem(name)
#                    item.setEditable(False)
#                    table_row.append(item)
#                model.appendRow(table_row)
#                print(table_row)
#                table_row = []
#            root_context.setContextProperty('listModel', model)


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
