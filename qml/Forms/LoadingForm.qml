import QtQuick 2.9
import QtQuick.Controls 2.4

Page {
    id: root

    signal refresh()

    property int status: -1

    BusyIndicator {
        anchors.centerIn: parent
    }
}
