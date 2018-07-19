import QtQuick 2.9
import QtQuick.Controls 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2

Page {
    id: root
    objectName: "MainPage"

    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: stackView.depth > 1
        onActivated: {
            stackView.pop()
        }
    }

    header: AppToolBar {


        Button {
            id:toolButton
            enabled: window.is_error === false
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: parent.width *0.02
            }
            height: parent.height - parent.height * 0.5
            width: height

            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }

            onPressed: toolButton.scale = 0.9
            onReleased: toolButton.scale = 1.0

            background: Image {
                source: stackView.depth > 1 ? "qrc:/graphics/icons/back.png" : "qrc:/graphics/icons/drawer.png"
                height: parent.height
                width: parent.width
                Behavior on scale {
                    PropertyAnimation {
                        duration: 100
                    }
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors {
                verticalCenter: parent.verticalCenter
                left: toolButton.right
                leftMargin: parent.width * 0.02
            }
            font.bold: true
            color: "white"
        }

        Image {
            id: logo
            source: stackView.currentItem.icon
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.02
            anchors.top: parent.top
            height: parent.height
            fillMode: Image.PreserveAspectFit
            mipmap: true
            Behavior on scale {
                PropertyAnimation {
                    duration: 100
                }
            }
            MouseArea {
                enabled: stackView.currentItem.link !== undefined && stackView.currentItem.objectName !== "WebsitePage"
                anchors.fill: parent
                onPressed: logo.scale = 0.9
                onReleased: logo.scale = 1.0
                onClicked: {
                    stackView.push("qrc:/WebsitePage.qml",{title: "Web", link: stackView.currentItem.link, icon: stackView.currentItem.icon})
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height
        AppToolBar {
            id: header
            showErrorBar: false
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            Label {
                text: "Menü"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 17
                }

                font.bold: true
            }
        }
        Column {
            anchors {
                top: header.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }


            ItemDelegate {
                text: qsTr("Fanny Webseite")
                width: parent.width
                onClicked: {
                    stackView.push("qrc:/WebsitePage.qml",{title: "Fanny Webseite", link: "http://www.fanny-leicht.de/j34", icon: stackView.currentItem.icon})
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
                        stackView.push("qrc:/FoodPlanForm.qml")
                    }
                }
            }

            ItemDelegate {
                Label {
                    text: "abmelden"
                    color: "red"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 17
                    }

                    font.bold: true
                }
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
                        root.StackView.view.push("qrc:/LoginPage.qml")
                    }
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "qrc:/HomeForm.qml"
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
        contentHeight: progressCircle.height
        contentWidth: progressCircle.width
        ProgressCircle {
            id: progressCircle
            size: 50
            lineWidth: 5
            anchors.centerIn: parent
            colorCircle: "#FF3333"
            colorBackground: "#E6E6E6"
             showBackground: true
             arcBegin: 0
             arcEnd: 0
             Label {
                 id: progress
                 anchors.centerIn: parent
                 text: "0%"
             }
             Timer {
                 id: refreshTimer
                 interval: 1;
                 running: busyDialog.visible
                 repeat: true
                 onTriggered: {
                     var ret = _cppServerConn.getProgress()
                     if(ret > 100 || ret < 0){
                         ret = 0
                     }

                     progress.text = Math.round( ret * 100 ) + "%"
                     progressCircle.arcEnd = 360 * ret
                 }
             }
        }
    }
}
