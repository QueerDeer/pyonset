import QtQuick 2.7
import QtQuick.Controls 1.4 //stable table-view
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("CSV-Parser")

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
                text: "Open csv..."
                onTriggered: fileDialog.open()
            }
            MenuItem {
                text: "Filter by..."
            }
        }

        FileDialog {
            id: fileDialog
            title: "Open file..."
            nameFilters: [ "csv files (*.csv)", "All files (*)" ]
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
                TableViewColumn {
                    role: "msgtype"
                    title: "MessageType"
                    width: 150
                }
                TableViewColumn {
                    role: "signtext"
                    title: "SignificantText"
                    width: 200
                }
                TableViewColumn {
                    role: "onenumb"
                    title: "OneNumber"
                    width: 150
                }
                TableViewColumn {
                    role: "anothernumb"
                    title: "AnotherNumber"
                    width: 150
                }

                model: listModel
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

}
