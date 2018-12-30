import Backend 1.0
import QtQuick 2.9
import QtQuick.Controls 2.4

FannyDataListView {
    id: foodList

    anchors.fill: parent

    model: FoodPlanModel {
        id: foodPlanModel
    }

    delegate: Button {
        id: delegate

        width: foodList.width
        height: contentCol.height + 10

        Column {
            id: contentCol

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }

            height: childrenRect.height + 10

            spacing: 2

            Label {
                id: cookteamLa
                // label for the cookteam

                width: parent.width
                wrapMode: Label.Wrap

                font.bold: true

                text: cookteam
            }

            Label {
                id: dateLa
                // label for the date

                width: parent.width
                wrapMode: Label.Wrap

                font.bold: true

                text: date
            }

            Rectangle {
                width: parent.width
                height: 2
                color: "grey"
            }

            Label {
                id: mainDishLa
                // label for the main dish

                width: parent.width
                wrapMode: Label.Wrap

                text: mainDish
            }

            Rectangle {
                width: parent.width / 10
                height: mainDishVegLa.text!=""? 1:0
                color: "grey"
            }

            Label {
                id: mainDishVegLa
                // label for the vegetarian main dish

                width: parent.width
                height: text!=""? undefined:0

                wrapMode: Label.Wrap

                text: mainDishVeg
            }

            Rectangle {
                width: parent.width / 10
                height: garnishLa.text!=""? 1:0
                color: "grey"
            }

            Label {
                id: garnishLa
                // label for the garnish

                width: parent.width
                height: text!=""? undefined:0

                wrapMode: Label.Wrap

                text: garnish
            }

            Rectangle {
                width: parent.width / 10
                height: dessertLa.text!=""? 1:0
                color: "grey"
            }

            Label {
                id: dessertLa
                // label for the dessert

                width: parent.width
                height: text!=""? undefined:0

                wrapMode: Label.Wrap

                text: dessert
            }
        }
    }
}




