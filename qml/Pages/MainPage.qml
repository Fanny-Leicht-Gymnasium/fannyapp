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

import QtQuick 2.2
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

import "../Components"
import "../Forms"

Page {
    id: root
    objectName: "MainPage"

    /*Shortcut {
        sequences: ["Esc", "Back"]
        enabled: formStack.depth > 1
        onActivated: {
            if(!formStack.currentItem.locked){
                formStack.pop()
            }
        }
    }*/

    Rectangle {
        anchors.fill: parent
        color: app.style.style.backgroundColor
    }

    StackView {
        id: formStack
        property var currPage
        property string eventDay: ""

        anchors {
            top: toolBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        onCurrPageChanged: {
            mainStack.replace(currPage)
        }

        onCurrentItemChanged: {
            formStack.currentItem.opened()
        }

        initialItem: homeForm

        Component {
            id: homeForm
            HomeForm {}
        }

        Component {
            id: foodPlanForm
            FoodPlanForm {}
        }

        Component {
            id: eventForm
            EventForm {
                day: formStack.eventDay
            }
        }

        Component {
            id: settingsForm
            SettingsForm {}
        }

        Component {
            id: filterForm
            FilterForm {}
        }

        popEnter: Transition {
            XAnimator {
                from: (formStack.mirrored ? -1 : 1) * -formStack.width
                to: 0
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        popExit: Transition {
            XAnimator {
                from: 0
                to: (formStack.mirrored ? -1 : 1) * formStack.width
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        pushEnter: Transition {
            XAnimator {
                from: (formStack.mirrored ? -1 : 1) * formStack.width
                to: 0
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        pushExit: Transition {
            XAnimator {
                from: 0
                to: (formStack.mirrored ? -1 : 1) * -formStack.width
                duration: 500
                easing.type: Easing.OutCubic
            }
        }
    }

    AppToolBar {
        id: toolBar

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: -60
        }

        height: 50

        Button {
            id:toolButton
            enabled: true
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: parent.width *0.02
            }
            height: parent.height - parent.height * 0.5
            width: height

            onClicked: {
                if(!formStack.currentItem.locked){
                    formStack.pop()
                }
            }

            onPressed: toolButton.scale = 0.9
            onReleased: toolButton.scale = 1.0

            background: Image {
                source: app.style.style.backIcon
                height: parent.height
                width: parent.width
                fillMode: Image.PreserveAspectFit
                Behavior on scale {
                    PropertyAnimation {
                        duration: 100
                    }
                }
            }
        }

        Label {
            text: getText()
            anchors {
                verticalCenter: parent.verticalCenter
                left: toolButton.right
                leftMargin: parent.width * 0.02
            }
            font.bold: true
            color: app.style.style.textColor

            function getText(){
                var titleString = "";
                for(var i=1; i<formStack.depth; i++){
                    if(i > 1){
                        titleString += " > "
                    }

                    titleString += formStack.get(i).title
                }
                return(titleString)
            }
        }

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        states: [
            State {
                name: "closed"
                when: formStack.depth === 1
                PropertyChanges {
                    target: toolBar
                    anchors.topMargin: -60
                }
            },
            State {
                name: "open"
                when: formStack.depth > 1
                PropertyChanges {
                    target: toolBar
                    anchors.topMargin: 0
                }
            }
        ]
    }
}
