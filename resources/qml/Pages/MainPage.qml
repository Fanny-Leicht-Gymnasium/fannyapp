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
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3

import "../Components"
import "../Forms"

Page {
    id: root
    objectName: "MainPage"

    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: formStack.depth > 1
        onActivated: {
            if(!formStack.currentItem.locked){
                formStack.pop()
            }
        }
    }

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

        Component {
            id: postMortumForm
            PostMortumForm {}
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
            topMargin: -60
        }

        height: 50
        width: parent.width

        RowLayout {

            anchors.fill: parent

            spacing: width * 0.02

            CompatibleToolButton {
                id: backTb

                enabled: !formStack.currentItem.locked

                opacity: enabled ? 1:0.5

                text: "\u0082"//"\u2039"

                onClicked: {
                    if(!formStack.currentItem.locked){
                        formStack.pop()
                    }
                }

            }

            Label {

                Layout.fillWidth: true

                text: getText()

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

            CompatibleToolButton {
                id: pdfTb

                enabled: !formStack.currentItem.locked

                opacity: enabled ? 1:0.5

                visible: formStack.currentItem.title === "Vertretungsplan"

                text: "\u0084"//"pdf ansehen"

                onClicked: {
                    if(formStack.currentItem.pdfAction !== undefined) {
                        formStack.currentItem.pdfAction()
                    }
                }
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


