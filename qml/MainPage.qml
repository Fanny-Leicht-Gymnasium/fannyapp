import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: root
    objectName: "MainPage"
    anchors.fill: parent

    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: stackView.depth > 1
        onActivated: {
            stackView.pop()
            listView.currentIndex = -1
        }
    }

    header: AppToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 5
            }

            background: Label {
                text: stackView.depth > 1 ? "\u25C0" : "\u4E09"
                font.pixelSize: Qt.application.font.pixelSize * 2
                color: "white"
            }

            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
            color: "white"
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent
            ItemDelegate {
                text: qsTr("Fanny Webseite")
                width: parent.width
                onClicked: {
                    stackView.push("WebsitePage.qml")
                    drawer.close()
                }
            }

            ItemDelegate {
                text: qsTr("Speiseplan")
                width: parent.width
                onClicked: {
                    busyDialog.open()
                    var ret = _cppServerConn.getFoodPlan();
                    drawer.close()
                    busyDialog.close()
                    if(ret === 200 || _cppServerConn.getFoodPlanData(1).cookteam !== ""){
                        stackView.push("FoodPlanForm.qml")
                    }
                }
            }

            ItemDelegate {
                text: qsTr("abmelden")
                width: parent.width
                onClicked: {
                    confirmationDialog.open()
                }
                Dialog {
                    id: confirmationDialog

                    x: (window.width - width) / 2
                    y: (window.height - height) / 2
                    parent: ApplicationWindow.overlay


                    modal: true
                    standardButtons: Dialog.Cancel | Dialog.Ok
                    Column {
                        spacing: 20
                        anchors.fill: parent
                        Label {
                            text: "Möchtest du dich wirklich abmelden?"
                        }
                    }
                    onAccepted: {
                        _cppServerConn.logout()
                        drawer.close()
                        root.StackView.view.push("LoginPage.qml")
                    }
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "HomeForm.qml"
        anchors.fill: parent
    }

    Dialog {
        id: busyDialog
        modal: true
        focus: true
        //title: "Please wait..."
        x: (window.width - width) / 2
        y: window.height / 6
        //width: Math.min(window.width, window.height) / 3 * 2
        height: contentHeight * 1.5
        width: contentWidth * 1.5
        contentHeight: busyIndicator.height
        contentWidth: busyIndicator.width
        BusyIndicator {
            id: busyIndicator
            visible: true
            anchors.centerIn: parent
            Label {
                id: progress
                anchors.centerIn: parent
                text: _cppServerConn.getProgress()
            }
            Timer {
                id: refreshTimer
                interval: 1;
                running: busyDialog.visible
                repeat: true
                onTriggered: {
                    var ret = _cppServerConn.getProgress()
                    progress.text = Math.round( ret * 100 ) + "%"
                    progressBar.value = ret
                }
            }
        }
        ProgressBar {
            id: progressBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: busyDialog.height / 1.5
        }
    }
}
