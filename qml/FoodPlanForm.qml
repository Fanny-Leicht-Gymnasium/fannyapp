import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Page {
    id:root
    anchors.fill: parent
    property bool cookplanChanged
    title: qsTr("Speiseplanplan")

//    Image{
//        source: "qrc:/graphics/chat_background.jpg";
//        height: parent.height
//        width: parent.width
//        fillMode: Image.Tile
//        horizontalAlignment: Image.AlignLeft
//        verticalAlignment: Image.AlignTop
//    }
    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(0, parent.height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4db2b3" }
            GradientStop { position: 1.0; color: "#8f4dae" }
        }
    }

    Timer {
        id: firstLoadTimer
        interval: 1;
        running: true
        repeat: false

        onTriggered: {
            _cppServerConn.getFoodPlan()
            cookplanChanged = true
        }
    }

    ScrollView {
        anchors.fill: parent

        ListView {
            id: listView
            width: parent.width
            model: 8
            spacing: 0
            property var today: new Date
            anchors {
                right: parent.right
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: 5
                rightMargin: 5
                topMargin: 3
            }

            delegate: Button {
                //text: getText(index, "cookteam")
                width: parent.width
                id: delegate
                height: listView.isDayVisible(index) ? childrenRect.height:0
                visible: listView.isDayVisible(index)

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    font.bold: true
                    id: cookteam
                    text: _cppServerConn.getFoodPlanData(index).cookteam
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: cookteam.bottom
                    font.bold: true
                    id: date
                    text: listView.getDateString(index)
                }
                Rectangle {
                    anchors.top:  date.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    height: 1
                    color: "grey"
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: date.bottom
                    id: main_dish
                    text: _cppServerConn.getFoodPlanData(index).main_dish
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: main_dish.bottom
                    id: main_dish_veg
                    text: _cppServerConn.getFoodPlanData(index).main_dish_veg
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: main_dish_veg.bottom
                    id: garnish
                    text: _cppServerConn.getFoodPlanData(index).garnish
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: garnish.bottom
                    id: dessert
                    text: _cppServerConn.getFoodPlanData(index).dessert
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: dessert.bottom
                    id: spacer
                    text: ""
                }
            }

            function getDateString(index){
                var date = _cppServerConn.getFoodPlanData(index).date
                //console.log(date)
                if(date.getDate() === today.getDate()){
                    return("Heute")
                }
                else if(date.getDate() === today.getDate() + 1 || (date.getDay() === 1 && today.getMonth() === date.getMonth() + 1)){
                    return("Morgen")
                }
                else {
                    return(Qt.formatDateTime(_cppServerConn.getFoodPlanData(index).date, "dddd, d.M.yy"))
                }

            }
            function isDayVisible(index){
                var date = _cppServerConn.getFoodPlanData(index).date
                return( date.getDate() >= today.getDate() || date.getMonth() > today.getMonth())
            }
        }
    }
}
