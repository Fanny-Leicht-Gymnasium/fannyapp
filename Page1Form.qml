import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    width: 600
    height: 400

    objectName: "Page1";

    property string title: "value"

    title: qsTr(title)

    Label {
        text: qsTr("You are on Page 1.")
        anchors.centerIn: parent
    }
    BusyIndicator {
        id: busyIndicator
        visible: true
        x: 40
        y: 49
    }


}
