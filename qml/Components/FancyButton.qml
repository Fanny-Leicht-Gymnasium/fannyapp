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
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.3

Button {
    id: control

    property string image
    property real imageScale: 1
    property color color: app.style.style.buttonColor


    scale: control.pressed ? 0.8:1

    Behavior on scale {
        PropertyAnimation {
            duration: 100
        }
    }

    background: Item {
        id: controlBackgroundContainer

        RectangularGlow {
            id: effect
            glowRadius: 0.001
            spread: 0.2
            color: "black"
            opacity: 1
            cornerRadius: controlBackground.radius
            anchors.fill: controlBackground
            scale: 0.75
        }

        Rectangle {
            id: controlBackground

            anchors.fill: parent

            radius: height * 0.5

            color: control.color

            Image {
                id: buttonIcon
                source: control.image

                anchors.centerIn: parent
                height: parent.height * 0.5
                width: height

                mipmap: true

                fillMode: Image.PreserveAspectFit

                scale: control.imageScale
            }
        }
    }

}
