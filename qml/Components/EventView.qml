import Backend 1.0
import QtQuick 2.9
import QtQuick.Controls 2.4

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

