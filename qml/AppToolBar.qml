import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

ToolBar {
    property bool showErrorBar: true
    Material.theme: Material.Light
    Rectangle {
        id: errorField
        width: parent.width
        height: 30
        visible: window.is_error & stackView.currentItem.objectName !== "LoginPage" & showErrorBar
        anchors.top: parent.bottom
        color: "red"
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            id: errorText
            font.family: "Helvetica"
            color: "White"
            font.pointSize: 8

            text: window.error
        }
    }
}
