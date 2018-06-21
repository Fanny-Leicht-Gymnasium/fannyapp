import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Universal 2.2

Page {
    width: 600
    height: 400

    title: qsTr("Page 2")

    Button {
        id: butt
        text: "test"
        width: parent.width
        height: 20

        background: Rectangle{
            id: background
            anchors.fill: parent
            color: "lightblue"
        }

        onReleased: {
            background.color = "lightblue"
        }

        onPressed: {
            background.color = "red"
        }

        anchors {
            top: parent.top
            left: parent.left
            leftMargin: window.width / 2 - butt.width / 2
            topMargin: 200
        }
    }
}
