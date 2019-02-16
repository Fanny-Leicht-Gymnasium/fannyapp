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

import QtQuick 2.9
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "../Components"

Page {
    id:root

    title: qsTr("Speiseplan")

    property int status: -1
    property bool locked: root.status === -1

    signal opened()

    onOpened: {}

    Loader {
        id: pageLoader

        property string newSource: ""

        onNewSourceChanged: {
            oldItemAnimation.start()
        }

        anchors.fill: parent
        source: "./LoadingForm.qml"

        onSourceChanged: {
            pageLoader.item.status = root.status
            newItemAnimation.start()
        }

        NumberAnimation {
            id: newItemAnimation
            target: pageLoader.item
            property: "opacity"
            from: 0
            to: 1
            duration: 200
            easing.type: Easing.InExpo
        }

        NumberAnimation {
            id: oldItemAnimation
            target: pageLoader.item
            property: "opacity"
            from: 1
            to: 0
            duration: 200
            easing.type: Easing.InExpo

            onRunningChanged: {
                if(!running){
                    pageLoader.source = pageLoader.newSource
                }
            }
        }

        Connections {
            target: pageLoader.item
            onRefresh: {
                pageLoader.newSource = "./LoadingForm.qml"
                loadTimer.start()
            }
        }
    }

    Timer {
        id: loadTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: {
            root.status = serverConn.getFoodPlan()
            pageLoader.newSource = "../Components/FoodPlanView.qml"
        }
    }
}
