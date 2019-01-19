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

import Backend 1.0
import QtQuick 2.9
import QtQuick.Controls 2.4

ListView {
    id: control

    property int status: -1

    signal refresh()

    anchors.fill: parent
    anchors.margins: 10
    anchors.rightMargin: 14

    ScrollBar.vertical: ScrollBar {
        parent: control.parent

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            margins: 10
            rightMargin: 3
        }

        width: 8

        active: true
    }

    onContentYChanged: {
        if(contentY < -125){
            control.refresh()
        }
    }

    InfoArea {
        id: infoArea

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: app.landscape() ? parent.width * 0.4:parent.width * 0.3
            topMargin: parent.height*( status === 901 ? 0.6:0.5) - height * 0.8
        }

        excludedCodes: [200, 902]
        errorCode: control.status
    }
}
