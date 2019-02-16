/*
    Fannyapp - Application to view the cover plan of the Fanny-Leicht-Gymnasium ins Stuttgart Vaihingen, Germany
    Copyright (C) 2019  Itsblue Development <development@itsblue.de>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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

                text: mainDish === "" ? "Aktuell keine Daten":mainDish
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




