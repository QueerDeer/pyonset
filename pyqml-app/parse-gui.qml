import QtQuick 2.7
import QtQuick.Controls 1.4 //stable table-view
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2

ApplicationWindow {
    visible: true
    width: 960
    height: 540
    title: qsTr("LOG-Parser")

    //bar with core buttons/avaliable options: open files, look-in hystory?, filter content
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                id: menuButton
                text: qsTr("⋮")
                onClicked: menu.open()
            }
            Label {
                id: helm
                text: "Title"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr("‹")
                onClicked: swipeView.currentIndex--

            }
            ToolButton {
                text: qsTr("›")
                onClicked: swipeView.currentIndex++
            }
        }

        Menu {
            id: menu
            y: menuButton.height

            MenuItem {
                text: "Open log..."
                onTriggered: fileDialog.open()
            }
            MenuItem {
                text: "Filter by..."
            }
        }

        FileDialog {
            id: fileDialog
            title: "Open file..."
            nameFilters: [ "log files (*.log)", "All files (*)" ]
            onAccepted: {
                parser.openfile(fileDialog.fileUrl)
                helm.text = fileDialog.fileUrl
            }
            onRejected: {
                Qt.quit()
            }
        }

    }

    SwipeView {
        id: swipeView
        anchors.fill: parent

        //page with the parsed content
        Page {
            TableView {
                id: tableView
                anchors.fill: parent
                selectionMode: SelectionMode.ExtendedSelection

                TableViewColumn {
                    role: "timestamp"
                    title: "TimeStamp"
                    width: 195
                }
                TableViewColumn {
                    role: "msgtype"
                    title: "MessageType"
                    width: 135
                }
                TableViewColumn {
                    role: "sigsource"
                    title: "SignalSource"
                    width: 135
                }
                TableViewColumn {
                    role: "msgcontent"
                    title: "MessageContent"
                    width: 495
                }

                //highlitning special messages
                rowDelegate: Component {
                    Rectangle {
                        color: if (styleData.selected)
                                   "slateblue"
                               else if (listModel.get(styleData.row).msgtype === "ERROR")
                                   "crimson"
                               else if (listModel.get(styleData.row).msgtype === "WARNING")
                                   "yellow"
                               else
                                   "white"
                        border.color: "gainsboro"
                        border.width: 0 //dunno, am i in need of'em, too thick
                    }
                }

                //text contrast for more comfortable viewing
                itemDelegate: Item {
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: listModel.get(styleData.row).msgtype === "ERROR" ? "white" : "black"
                        elide: Text.ElideMiddle
                        text: styleData.value
                    }
                }

                model: listModel
            }

            //core plug for creating roles (existing tablecolumn's roles isn't enough for the first uploading)
            ListModel{
                id:listModel
                ListElement{
                    timestamp: "0000.00.00 00:00:00.000"
                    msgtype: "-------"
                    sigsource: "--------"
                    msgcontent: "@0000000=0 - elapsed time[ms]: 0 returns [0000000000; 0000000000]"
                }
            }

        }

        //reserve page
        Page {
            Label {
                text: qsTr("For some reasons in future")
                anchors.centerIn: parent
            }
        }
    }

    Connections {
        target: parser

        // new row signal handler
        onRowAdd: {
            listModel.append({"timestamp": model1, "msgtype": model2, "sigsource": model3, "msgcontent": model4})
        }

        // clear tableview (plug's roles were saved)
        onSetUp: {
            listModel.clear()
        }
    }

}
