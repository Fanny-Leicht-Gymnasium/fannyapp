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
import QtQuick 2.1
import QtQuick.Controls 2.2

FannyDataListView {
    id: eventList

    anchors.fill: parent

    model: EventModel {
        id: foodPlanModel
    }


    delegate: Button {
        id: delegate

        width: eventList.width
        height: contentCol.height + 10

        Column {
            id: contentCol

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }

            height: childrenRect.height + 10

            spacing: 1

            Label {
                id: gradeLa
                // label for the grade

                font.bold: true
                font.pixelSize: hourReplaceSubjectRoomLa.font.pixelSize * 1.5

                width: parent.width - 10
                wrapMode: Label.Wrap

                text: grade
            }

            Label {
                id: hourReplaceSubjectRoomLa
                // label for the hour, replacement, subject and room

                width: parent.width - 10
                wrapMode: Label.Wrap

                text: hour + ( replace === "" ? "": ( " | "
                      + replace + ( subject === "" ? "": ( " | "
                      + subject + ( room === "" ? "": ( " | "
                      + room ) ) ) ) ) )
            }

            Label {
                id: toTextLa
                // label for the new room (to) and the additional text (text)

                width: parent.width - 10
                wrapMode: Label.Wrap

                font.pixelSize: gradeLa.font.pixelSize
                font.bold: true

                visible: text !== ""

                text: to !== "" && model.text !== "" ? to + " | " + model.text:model.to + model.text
            }
        }

    }
}

