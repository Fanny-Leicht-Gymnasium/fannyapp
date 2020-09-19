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

import QtQuick 2.0
import QtQuick.Controls 2.2

ItemDelegate {
    id: control

    property string title: ""
    property string description: ""
    property bool showForwardIcon: true

    height: 10 + shortDescription.height + 2 + longDescription.height + 10

    Label {
        id: shortDescription

        anchors {
            top: parent.top
            left: parent.left
            margins: 10
        }

        font.pixelSize: longDescription.font.pixelSize * 1.4

        text: control.title

        color: app.style.style.textColor

    }

    Label {
        id: longDescription

        anchors {
            top: shortDescription.bottom
            topMargin: 2
            left: parent.left
            leftMargin: 10
        }

        width: parent.width * 0.85

        wrapMode: Label.Wrap

        text: control.description

        color: app.style.style.textColor

        onLinkActivated: {
            Qt.openUrlExternally(link)
        }
    }

    Text {
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 10
        }

        visible: control.showForwardIcon
        rotation: 180
        text: "\u0082"

        font.pixelSize: parent.height * 0.4
        font.family: iconFont.name
        color: app.style.style.textColor
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    FontLoader {
        id: iconFont
        source: "qrc:/fonts/IconFont.otf"
    }

}
