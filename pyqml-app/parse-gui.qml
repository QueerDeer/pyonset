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
    height: 680
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
                id: filterbutton
                text: "Filter by..."
                onTriggered: submenu1.open()
                enabled: false

                 //sources and types were bind hardly, but we can try to add items dynamically, if it really needs
                 //or, maybe, allow user to choose a list of filters in one time
                 Menu {
                    id: submenu1
                    MenuItem {
                        text: "Nothing"
                        onTriggered: parser.filterbytypesource("", "msgtype")
                    }
                    MenuItem{
                        text: "Period"
                        onTriggered: period.open()
                    }
                    MenuItem {
                        text: "Debug type"
                        onTriggered: parser.filterbytypesource("DEBUG", "msgtype")
                    }
                    MenuItem {
                        text: "Error type"
                        onTriggered: parser.filterbytypesource("ERROR", "msgtype")
                    }
                    MenuItem {
                        text: "Warning type"
                        onTriggered: parser.filterbytypesource("WARNING", "msgtype")
                    }
                    MenuItem {
                        text: "Signal source"
                        onTriggered: submenu2.open()

                        Menu {
                           id: submenu2
                           MenuItem {
                               text: "GtDict"
                               onTriggered: parser.filterbytypesource("GtDict", "sigsource")
                           }
                           MenuItem {
                               text: "GtFrame"
                               onTriggered: parser.filterbytypesource("GtFrame", "sigsource")
                           }
                           MenuItem {
                               text: "GtMeas"
                               onTriggered: parser.filterbytypesource("GtMeas", "sigsource")
                           }
                           MenuItem {
                               text: "GtSp3"
                               onTriggered: parser.filterbytypesource("GtSp3", "sigsource")
                           }
                           MenuItem {
                               text: "GtState"
                               onTriggered: parser.filterbytypesource("GtState", "sigsource")
                           }
                           MenuItem {
                               text: "PsSp3"
                               onTriggered: parser.filterbytypesource("PsSp3", "sigsource")
                           }
                       }
                    }
                }
            }
        }

        FileDialog {
            id: fileDialog
            title: "Open file..."
            nameFilters: [ "log files (*.log)", "All files (*)" ]
            onAccepted: {
                parser.openfile(fileDialog.fileUrl)
                helm.text = fileDialog.fileUrl
                filterbutton.enabled = true
            }
        }

        Dialog {
            id: period
            title: "LOG-Parser"
            //width: 420
            standardButtons: Dialog.Ok | Dialog.Cancel
            onAccepted: parser.filterbytime(first.text, last.text)

            ColumnLayout {
                anchors.fill: parent

                Label {
                    text: qsTr("Set the timestamp limit for represented content")
                }

                RowLayout {

                    TextInput {
                        id: first
                        text: ""
                    }

                    Label {
                        text: "-"
                    }

                    TextInput {
                        id: last
                        text: ""
                    }
                }
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
                    msgtype: "DEBUG"
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

        // set limits of "dialog"'s filtering limits
        onUpdatePeriod: {
            first.text = mesg1
            last.text = mesg2
        }
    }

}
