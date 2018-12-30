import QtQuick 2.9
import QtQuick.Controls 2.4

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

