import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    anchors.fill: parent

    title: qsTr("Speiseplanplan")
    property bool loaded: false

    Timer {
        id: firstLoadTimer
        interval: 1;
        running: true
        repeat: false
        onTriggered: {
            _cppServerConn.getFoodPlan()
            loaded = true
        }
    }

    ScrollView {
        anchors.fill: parent

        ListView {
            enabled: loaded
            width: parent.width
            model: 8
            delegate: ItemDelegate {
                //text: getText(index, "cookteam")
                width: parent.width
                Label {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    id: cookteam
                    text: _cppServerConn.getFoodPlanData(index).cookteam
                }
                Label {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    id: date
                    text: _cppServerConn.getFoodPlanData(index).date
                }
            }
        }

    }
    function getText(indexvar, type){
        if(!loaded){
            _cppServerConn.getFoodPlan()
            loaded = true
        }
        //console.log(_cppServerConn.getFoodPlanData(indexvar))
    }
}
