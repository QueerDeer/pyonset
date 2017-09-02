import QtQuick 2.7
import QtQuick.Controls 1.4 //stable table-view
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.1    

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
                text: qsTr("⋮")
                onClicked: menu.open()
            }
            Label {
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
            }
            MenuItem {
                text: "Filter by..."
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
