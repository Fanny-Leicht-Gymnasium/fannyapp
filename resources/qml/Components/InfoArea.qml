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

    property var optionButtonFunction: undefined

    visible: !(excludedCodes.indexOf(errorCode) >= 0)

    Column {
        anchors.centerIn: parent

        width: parent.width * 0.8

        opacity: infoArea.errorCode !== 200 && infoArea.errorCode !== (-1) ? 1:0

        spacing: 20

        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            radius: height * 0.5
            width: app.landscape() ? infoArea.height * 0.4 : parent.width * 0.5
            height: width

            color: "transparent"
            border.width: 5
            border.color: ["green", "grey", "orange", "red"][infoArea.alertLevel]

            Label {
                anchors.centerIn: parent
                font.pixelSize: parent.height * 0.8
                text: infoArea.alertLevel > 1 ? "!":"i"
                color: parent.border.color
            }

        }

        Label {
            id: errorShortDescription
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            width: parent.width

            wrapMode: Label.Wrap

            horizontalAlignment: Label.AlignHCenter

            font.pixelSize: errorLongDescription.font.pixelSize * 1.8
            text: app.getErrorInfo(infoArea.errorCode)[1]
        }

        Label {
            id: errorLongDescription
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            width: parent.width

            wrapMode: Label.Wrap

            horizontalAlignment: Label.AlignHCenter

            text: app.getErrorInfo(infoArea.errorCode)[2]
        }

        Button  {
            id: optionButton

            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            visible: text !== "" && infoArea.optionButtonFunction !== undefined

            text: app.getErrorInfo(infoArea.errorCode)[3]

            onClicked: {
                infoArea.optionButtonFunction()
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 500
            }
        }
    }

}

