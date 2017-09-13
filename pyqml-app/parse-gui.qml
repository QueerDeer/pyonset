import QtQuick 2.7
import QtQuick.Controls 1.4 //stable table-view
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: window
    visible: true
    visibility: "Windowed"
    width: 960
    height: 680
    title: qsTr("LOG-Parser")

    //bar with core buttons/avaliable options: open files, look-in stuff, filter content
    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            ToolButton {
                text: "□"
                font.pointSize: 12
                onClicked: {
                    if (text === "◱")
                    {
                        text = "□"
                        window.visibility = "Windowed"
                    }
                    else
                    {
                        text = "◱"
                        window.visibility = "FullScreen"
                    }
                }
            }

            ToolButton {
                id: menuButton
                text: "File"
                onClicked: fileDialog.open()
            }

            Label {
                id: helm
                text: "Title"
                anchors.left: menuButton.right
                anchors.right: filterButton0.left
                anchors.rightMargin: 34
                anchors.leftMargin: 34
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                id:filterButton0
                text: qsTr("Duration")
                enabled: false
                onClicked: longpop.open()
                anchors.right: filterButton1.left
                anchors.rightMargin: 34

                Popup {
                    id: longpop
                    y: 49

                    TextField {
                        id: duration
                        placeholderText: "XYZms"
                        text: ""
                    }
                }

            }

            ToolButton {
                id:filterButton1
                text: qsTr("Period")
                enabled: false
                onClicked: timepop.open()
                anchors.right: filterButton2.left
                anchors.rightMargin: 34

                Popup {
                    id: timepop
                    y: 49

                    RowLayout {
                        TextField {
                            id: first
                            text: ""
                            placeholderText: "00:00:00.000"
                        }

                        Label {
                            text: "-"
                        }

                        TextField {
                            id: last
                            text: ""
                            placeholderText: "00:59:59.999"
                        }
                    }
                }

            }

            ToolButton {
                id:filterButton2
                text: qsTr("Type")
                enabled: false
                onClicked: typepop.open()
                anchors.right: filterButton3.left
                anchors.rightMargin: 34

                Popup {
                    id:typepop
                    y: 49
                    Column {
                        CheckBox {
                            id: debug
                            text: "DEBUG"
                            checked: false
                        }
                        CheckBox {
                            id: error
                            text: "ERROR"
                            checked: false
                        }
                        CheckBox {
                            id: info
                            text: "INFO   "
                            checked: false
                        }
                        CheckBox {
                            id: warning
                            text: "WARNING"
                            checked: false
                        }
                    }
                }

            }

            ToolButton {
                id:filterButton3
                text: qsTr("Source")
                enabled: false
                onClicked: sourcepop.open()
                anchors.right: filterButton4.left
                anchors.rightMargin: 34

                Popup {
                    id: sourcepop
                    y: 49
                    Column {
                        CheckBox {
                            id: gtDict
                            text: "GtDict"
                            checked: true
                        }
                        CheckBox {
                            id: gtFrame
                            text: "GtFrame"
                            checked: true
                        }
                        CheckBox {
                            id: gtMeas
                            text: "GtMeas"
                            checked: true
                        }
                        CheckBox {
                            id: gtSp3
                            text: "GtSp3"
                            checked: true
                        }
                        CheckBox {
                            id: gtState
                            text: "GtState"
                            checked: true
                        }
                        CheckBox {
                            id: psSp3
                            text: "PsSp3"
                            checked: true
                        }
                        CheckBox {
                            id: none
                            text: "None"
                            checked: true
                        }
                    }
                }

            }

            ToolButton {
                id:filterButton4
                text: qsTr("Substring")
                enabled: false
                onClicked: subspop.open()
                anchors.right: acceptButton.left
                anchors.rightMargin: 34

                Popup {
                    id: subspop
                    y: 49

                    TextField {
                        id: substring
                        placeholderText: "something..."
                        text: ""
                    }
                }

            }

            ToolButton {
                id: acceptButton
                text: qsTr("✓")
                font.pointSize: 17
                anchors.right: parent.right
                onClicked: {
                    var param1 = []
                    var param2 = []

                    if (debug.checked === true) param1.push(debug.text)
                    if (error.checked === true) param1.push(error.text)
                    if (info.checked === true) param1.push(info.text)
                    if (warning.checked === true) param1.push(warning.text)

                    if (gtDict.checked === true) param2.push(gtDict.text)
                    if (gtFrame.checked === true) param2.push(gtFrame.text)
                    if (gtMeas.checked === true) param2.push(gtMeas.text)
                    if (gtSp3.checked === true) param2.push(gtSp3.text)
                    if (gtState.checked === true) param2.push(gtState.text)
                    if (psSp3.checked === true) param2.push(psSp3.text)
                    if (none.checked === true) param2.push(none.text)

                    parser.queuedfilter(first.text, last.text, JSON.stringify(param1), JSON.stringify(param2), substring.text)
                }
                enabled: false
            }

        }

        FileDialog {
            id: fileDialog
            title: "Open file..."
            nameFilters: [ "log files (*.log)", "All files (*)" ]
            onAccepted: {
                swipeView.currentIndex = 1
                parser.openfile(fileDialog.fileUrl)
                helm.text = fileDialog.fileUrl
                acceptButton.enabled = true
                filterButton0.enabled = true
                filterButton1.enabled = true
                filterButton2.enabled = true
                filterButton3.enabled = true
                filterButton4.enabled = true
            }
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        orientation: Qt.Vertical
        currentIndex: 2
        interactive: true //false, if you don't drug scene by table's headers

        Page {
            Rectangle {
                anchors.fill: parent
                color: "#FCF0E4"
            }

            ColumnLayout {
                anchors.bottom: parent.bottom
                AnimatedImage {
                    visible: easteregg.position == 1.0 ? true : false
                    paused: easteregg.position == 0.0 ? true : false
                    source: "https://bunusevdim.files.wordpress.com/2014/06/tumblr_ly4m2qwepw1qhy6c9o2_r1_500_thumb.gif?w=240&h=168"
                }
                Switch{
                    id: easteregg
                }
            }

        }

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
                                   "snow"
                        border.color: "gainsboro"
                        border.width: 0 //dunno, am i in need of'em, too thick
                    }
                }

                //text contrast for more comfortable viewing
                itemDelegate: Item {
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: listModel.get(styleData.row).msgtype === "ERROR" ? "snow" : "black"
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
