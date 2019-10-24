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
import QtQuick.Controls 2.2

Item {
    id: infoArea

    property int alertLevel: app.getErrorInfo(infoArea.errorCode)[0]
        // 0 - ok
        // 1 - info
        // 2 - error
    property int errorCode: -1
    property var excludedCodes: []

    visible: !(excludedCodes.indexOf(errorCode) >= 0)

    height: childrenRect.height

    Rectangle {

        radius: height * 0.5
        width: parent.width
        height: width

        color: "transparent"
        border.width: 5
        border.color: infoArea.alertLevel > 0 ? infoArea.alertLevel > 1 ? "red":"grey" : "green"

        opacity: infoArea.errorCode !== 200 && infoArea.errorCode !== (-1) ? 1:0

        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }

        Label {
            anchors.centerIn: parent
            font.pixelSize: parent.height * 0.8
            text: infoArea.alertLevel > 1 ? "!":"i"
            color: infoArea.alertLevel > 0 ? infoArea.alertLevel > 1 ? "red":"grey" : "green"
        }

        Label {
            id: errorShortDescription
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.bottom
                margins: parent.height * 0.1
            }

            width: app.width * 0.8

            wrapMode: Label.Wrap

            horizontalAlignment: Label.AlignHCenter

            font.pixelSize: errorLongDescription.font.pixelSize * 1.8
            text: app.getErrorInfo(infoArea.errorCode)[1]
        }

        Label {
            id: errorLongDescription
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: errorShortDescription.bottom
                margins: parent.height * 0.1
            }

            width: app.width * 0.8

            wrapMode: Label.Wrap

            horizontalAlignment: Label.AlignHCenter

            text: app.getErrorInfo(infoArea.errorCode)[2]
        }
    }

}

