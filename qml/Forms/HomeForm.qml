/*
    Fannyapp - Application to view the cover plan of the Fanny-Leicht-Gymnasium ins Stuttgart Vaihingen, Germany
    Copyright (C) 2019  Itsblue Development <development@itsblue.de>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.3

import "../Components"

Page {
    id: root

    property bool locked: false

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
                    formStack.eventDay = 0
                    formStack.push(eventForm)
                }
            }

            FancyButton {
                id: tomorrowButton

                image: "qrc:/graphics/icons/smorgen.png"

                width: mainMenu.buttonWidth
                height: mainMenu.buttonHeight

                onClicked: {
                    formStack.eventDay = 1
                    formStack.push(eventForm)
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

                image: app.style.style.treffpunktFannyIcon

                width: smallMenu.buttonWidth
                height: smallMenu.buttonHeight

                onClicked: {
                    formStack.push(foodPlanForm)
                }
            }

            FancyButton {
                id: fannyButton

                image: app.style.style.fannyLogo
                imageScale: 1.2

                width: smallMenu.buttonWidth
                height: smallMenu.buttonHeight

                onClicked: {
                    Qt.openUrlExternally("http://www.fanny-leicht.de")
                }
            }

            FancyButton {
                id: settingsButton

                image: app.style.style.settingsIcon
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

                    Material.theme: app.style.style.nameMaterialStyle === "Dark" ? Material.Dark:Material.Light

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
