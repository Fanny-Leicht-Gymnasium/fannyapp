import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    anchors.fill: parent

    title: qsTr("Speiseplanplan")

    Label {
        id: laWelcome
        text: "Hier kannst du dir den Vertretungsplan des Fannys anschauen"
        font.pixelSize: 20
        wrapMode: Label.Wrap
        width: window.width / 1.2

        anchors {
            top: parent.top
        }
    }
    Button {
        id: butt
        text: "load"
        onClicked: {
            var ret = _cppServerConn.getFoodPlan();
            laWelcome.text = ret
        }
    }
}
