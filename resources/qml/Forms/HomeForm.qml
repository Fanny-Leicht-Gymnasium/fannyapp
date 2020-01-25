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

import QtQuick 2.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

import "../Components"

Page {
    id: root

    property bool locked: false

    signal opened()

    onOpened: {}

    Column {
        id: mainMenu
        spacing: buttonSize * 0.1

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        property int buttonSize: app.landscape() ? root.height * (0.5*0.8):root.width * (0.5*0.8)

        Row {
            id: bigMenu
            spacing: mainMenu.buttonSize * 0.1
            anchors.horizontalCenter: parent.horizontalCenter

            FancyButton {
                id: todayButton

                image: "qrc:/icons/sheute.png"

                size: mainMenu.buttonSize

                onClicked: {
                    formStack.eventDay = 0
                    formStack.push(eventForm)
                }
            }

            FancyButton {
                id: tomorrowButton

                image: "qrc:/icons/smorgen.png"

                size: mainMenu.buttonSize

                onClicked: {
                    formStack.eventDay = 1
                    formStack.push(eventForm)
                }
            }

        }

        Grid {
            id: smallMenu
            columns: app.landscape() ? 4:2
            spacing: mainMenu.buttonSize * 0.1

            anchors.horizontalCenter: parent.horizontalCenter

            property int buttonSize: mainMenu.buttonSize * 0.7

            FancyButton {
                id: foodplanButton

                image: app.style.style.treffpunktFannyIcon

                size: smallMenu.buttonSize

                onClicked: {
                    formStack.push(foodPlanForm)
                }
            }

            FancyButton {
                id: fannyButton

                image: app.style.style.fannyLogo
                imageScale: 1.2

                size: smallMenu.buttonSize

                onClicked: {
                    Qt.openUrlExternally("http://www.fanny-leicht.de")
                }
            }

            FancyButton {
                id: settingsButton

                image: app.style.style.settingsIcon
                imageScale: 0.8

                size: smallMenu.buttonSize

                onClicked: {
                    formStack.push(settingsForm)
                }
            }

            FancyButton {
                id: logoutButton

                image: "qrc:/icons/logoutRed.png"
                imageScale: 0.8

                size: smallMenu.buttonSize

                onClicked: {
                    logoutConfirmationDialog.open()
                }
            }
        }
    }

    Dialog {
        id: logoutConfirmationDialog

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        modal: true
        focus: true

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
