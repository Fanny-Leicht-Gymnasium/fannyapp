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
