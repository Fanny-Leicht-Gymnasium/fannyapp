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
//    LinearGradient {
//        anchors.fill: parent
//        start: Qt.point(0, 0)
//        end: Qt.point(0, parent.height)
//        gradient: Gradient {
//            GradientStop { position: 0.0; color: "#4db2b3" }
//            GradientStop { position: 1.0; color: "#8f4dae" }
//        }
//    }

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
                height: visible ? cookteam.height + date.height + main_dish.height + main_dish_veg.height + garnish.height + dessert.height + spacer.height + cust_spacing*9 + 5:0
                visible: listView.isDayVisible(index)

                property int cust_spacing: 5

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    font.bold: true
                    id: cookteam
                    text: _cppServerConn.getFoodPlanData(index).cookteam
                    width: parent.width - 10
                    wrapMode: Label.Wrap
                    height: text!=""? undefined:0
                }
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: cookteam.bottom
                    font.bold: true
                    id: date
                    text: listView.getDateString(index)
                    width: parent.width - 10
                    wrapMode: Label.Wrap
                }
                Rectangle {
                    anchors.top:  date.bottom
                    anchors.topMargin: cust_spacing
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    height: 2
                    color: "grey"

                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: date.bottom
                    anchors.topMargin: cust_spacing * 2
                    width: parent.width - 10
                    wrapMode: Label.Wrap
                    id: main_dish
                    text: _cppServerConn.getFoodPlanData(index).main_dish
                    height: text!=""? undefined:0
                }

                Rectangle {
                    anchors.top:  main_dish.bottom
                    anchors.topMargin: cust_spacing
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    width: parent.width / 10
                    height: main_dish_veg.text!=""? 1:0
                    color: "grey"

                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: main_dish.bottom
                    anchors.topMargin: cust_spacing * 2
                    id: main_dish_veg
                    text: _cppServerConn.getFoodPlanData(index).main_dish_veg
                    width: parent.width - 10
                    wrapMode: Label.Wrap
                    height: text!=""? undefined:0
                }

                Rectangle {
                    anchors.top:  main_dish_veg.bottom
                    anchors.topMargin: cust_spacing
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    width: parent.width / 10
                    height: garnish.text!=""? 1:0
                    color: "grey"
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: main_dish_veg.bottom
                    anchors.topMargin: cust_spacing * 2
                    id: garnish
                    text: _cppServerConn.getFoodPlanData(index).garnish
                    width: parent.width - 10
                    wrapMode: Label.Wrap
                    height: text!=""? undefined:0
                }

                Rectangle {
                    anchors.top:  garnish.bottom
                    anchors.topMargin: cust_spacing
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    width: parent.width / 10
                    height: dessert.text!=""? 1:0
                    color: "grey"

                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: garnish.bottom
                    anchors.topMargin: cust_spacing * 2
                    id: dessert
                    text: _cppServerConn.getFoodPlanData(index).dessert
                    width: parent.width - 10
                    wrapMode: Label.Wrap
                    height: text!=""? undefined:0
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: dessert.bottom
                    anchors.topMargin: cust_spacing
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
                else if(date.getDate() === today.getDate() + 1 || (date.getDate() === 1 && date.getMonth() === today.getMonth() + 1)){
                    return("Morgen")
                }
                else {
                    return(Qt.formatDateTime(_cppServerConn.getFoodPlanData(index).date, "dddd, d.M.yy"))
                }

            }
            function isDayVisible(index){
                var date = _cppServerConn.getFoodPlanData(index).date
                return( date.getDate() >= today.getDate() && date.getMonth() >= today.getMonth())
            }
        }
    }
}
