import QtQuick 2.0
import QtQuick.Controls 2.2

Page {
    id: root
    anchors.fill: parent

    Label {
        text: qsTr("You are on login")
        anchors.centerIn: parent
    }
    BusyIndicator {
        id: busyIndicator
        visible: true
        x: 40
        y: 49
    }
    Button {
        text: "main"
        height: 30
        width: 50

        onClicked: {
            var ret = _cppServerConn.login();

            root.StackView.view.push("MainPage.qml")
        }
    }


}
