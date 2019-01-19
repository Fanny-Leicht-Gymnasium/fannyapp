import QtQuick 2.9
import QtQuick.Controls 2.4

import "../Components"

Page {
    id: root

    signal opened()

    onOpened: {}

    Column {
        id: mainMenu
        spacing: buttonWidth * 0.1

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        property int buttonHeight: app.landscape() ? root.height * (0.5*0.8):buttonWidth
        property int buttonWidth: app.landscape() ? buttonHeight:root.width * (0.5*0.8)

        Row {
            id: bigMenu
            spacing: mainMenu.buttonWidth * 0.1
            anchors.horizontalCenter: parent.horizontalCenter

            FancyButton {
                id: todayButton

                image: "qrc:/graphics/icons/sheute.png"

                width: mainMenu.buttonWidth
                height: mainMenu.buttonHeight

                onClicked: {
                    eventConfirmationDialog.openDay( _cppAppSettings.loadSetting("teacherMode") === "true" ? "lheute":"sheute")
                }
            }

            FancyButton {
                id: tomorrowButton

                image: "qrc:/graphics/icons/smorgen.png"

                width: mainMenu.buttonWidth
                height: mainMenu.buttonHeight

                onClicked: {
                    eventConfirmationDialog.openDay( _cppAppSettings.loadSetting("teacherMode") === "true" ? "lmorgen":"smorgen")
                }
            }

            Dialog {
                property string day
                id: eventConfirmationDialog

                modal: true
                focus: true

                title: "Bedingung"

                x: (app.width - eventConfirmationDialog.width) / 2
                y: (app.height - eventConfirmationDialog.height) / 2
                parent: Overlay.overlay
                width: Math.min(root.width, root.height) / 3 * 2
                contentHeight: aboutColumn.height
                standardButtons: Dialog.Ok | Dialog.Cancel

                onAccepted: {
                    formStack.eventDay = day
                    formStack.push(eventForm)
                }

                Column {
                    id: aboutColumn
                    spacing: 20
                    Label {
                        id: text
                        visible: true
                        width: eventConfirmationDialog.availableWidth
                        wrapMode: Label.Wrap
                        text: "Vertretungsplan, vertraulich, nur zum persönlichen Gebrauch, keine Speicherung!"
                    }
                }

                function openDay(day){
                    eventConfirmationDialog.day = day
                    eventConfirmationDialog.open()
                }
            }

        }

        Grid {
            id: smallMenu
            columns: app.landscape() ? 4:2
            spacing: mainMenu.buttonWidth * 0.1

            anchors.horizontalCenter: parent.horizontalCenter

            property int buttonHeight: mainMenu.buttonHeight * 0.7
            property int buttonWidth: mainMenu.buttonWidth * 0.7

            FancyButton {
                id: foodplanButton

                image: "qrc:/graphics/images/TreffpunktFannyLogoDark.png"

                width: smallMenu.buttonWidth
                height: smallMenu.buttonHeight

                onClicked: {
                    formStack.push(foodPlanForm)
                }
            }

            FancyButton {
                id: fannyButton

                image: "qrc:/graphics/images/FannyLogoDark.jpg"
                imageScale: 1.2

                width: smallMenu.buttonWidth
                height: smallMenu.buttonHeight

                onClicked: {
                    Qt.openUrlExternally("http://www.fanny-leicht.de")
                }
            }

            FancyButton {
                id: settingsButton

                image: "qrc:/graphics/icons/settingsBlack.png"
                imageScale: 0.8

                width: smallMenu.buttonWidth
                height: smallMenu.buttonHeight

                onClicked: {
                    formStack.push(settingsForm)
                }
            }

            FancyButton {
                id: logoutButton

                image: "qrc:/graphics/icons/logoutRed.png"
                imageScale: 0.8

                width: smallMenu.buttonWidth
                height: smallMenu.buttonHeight

                onClicked: {
                    logoutConfirmationDialog.open()
                }

                Dialog {
                    id: logoutConfirmationDialog

                    x: (app.width - width) / 2
                    y: (app.height - height) / 2
                    parent: Overlay.overlay

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
                        serverConn.logout()
                    }
                }
            }
        }
    }
}
