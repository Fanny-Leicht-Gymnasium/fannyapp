import QtQuick 2.0
import QtQuick.Controls 2.4

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
    }

    Image {
        id: forwardIcon

        visible: control.showForwardIcon

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 10
        }

        height: parent.height * 0.4

        rotation: 180

        fillMode: Image.PreserveAspectFit

        source: "/graphics/icons/backDark.png"
    }

}
