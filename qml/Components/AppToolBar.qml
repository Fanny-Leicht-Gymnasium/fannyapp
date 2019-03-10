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

import QtQuick 2.6
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.3

Item {
    id: control
    height: 50
    property bool showErrorBar: true

    RectangularGlow {
        id: toolBarEffect
        glowRadius: 3
        spread: 0.2
        color: "black"
        opacity: 0.3
        anchors.fill: toolBar
    }

    Rectangle {
        id: toolBar
        color: app.style.style.menuColor
        anchors.fill: parent


//        anchors {
//            top: parent.top
//            left: parent.left
//            right: parent.right
//            topMargin: -60
//        }

        Rectangle {
            id: errorField
            width: parent.width
            height: 30
            enabled: app.is_error & app.state !== "notLoggedIn" & control.showErrorBar
            anchors.top: parent.bottom

            color: "red"
            onEnabledChanged: {
                if(enabled){
                    toolBar.state = 'moveIn'
                }
                else {
                    toolBar.state = 'moveOut'
                }
            }

            MouseArea { anchors.fill: parent; onClicked: {
                    toolBar.state = 'moveOut'

                    console.log("clicked")
                }
            }

            Text {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                id: errorText
                font.family: "Helvetica"
                color: "White"
                font.pointSize: 8
                visible: parent.height !== 0
                text: app.error
            }
        }

        states: [
            State {
                name: "moveOut"
                PropertyChanges { target: errorField; height: 0 }
            },
            State {
                name: "moveIn"
                PropertyChanges { target: errorField; height: 30 }
            }
        ]

        transitions: [
            Transition {
                to: "moveOut"
                NumberAnimation { properties: "height"; easing.type: Easing.InOutQuad; duration: 200 }
            },
            Transition {
                to: "moveIn"
                NumberAnimation { properties: "height"; easing.type: Easing.InOutQuad; duration: 200 }
            }
        ]
    }
}
