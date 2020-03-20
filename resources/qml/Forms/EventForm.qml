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
import Backend 1.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.0
import "../Components"

Page {
    id: root

    property string day

    title: qsTr("Vertretungsplan")

    property int status: -1
    property bool locked: root.status === -1

    signal opened()

    onOpened: {}

    function pdfAction() {
        busyDialog.open()
        serverConn.openEventPdf(day)
        busyDialog.close()
    }

    Loader {
        id: pageLoader

        property var newSourceComponent

        anchors.fill: parent
        sourceComponent: loadingFormComp

        onNewSourceComponentChanged: {
            oldItemAnimation.start()
        }

        onSourceComponentChanged: {
            if(pageLoader.item !== null) {
                pageLoader.item.status = root.status
                newItemAnimation.start()
            }
        }



        ParallelAnimation {
            id: newItemAnimation

            NumberAnimation {
                target: pageLoader.item
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.InExpo
            }

            NumberAnimation {
                target: pageLoader.item
                property: "scale"
                from: 0.98
                to: 1
                duration: 300
                easing.type: Easing.InExpo
            }
        }

        ParallelAnimation {
            id: oldItemAnimation

            NumberAnimation {
                target: pageLoader.item
                property: "opacity"
                from: 1
                to: 0
                duration: 300
                easing.type: Easing.InExpo
            }

            onRunningChanged: {
                if(!running){
                    pageLoader.sourceComponent = pageLoader.newSourceComponent
                }
            }
        }

        Component {
            id: eventListComp

            FannyDataListView {
                id: eventList

                status: 900

                optionButtonFunction: function() {
                    busyDialog.open()
                    serverConn.openEventPdf(day)
                    busyDialog.close()
                }

                model: EventModel {
                    id: foodPlanModel
                }

                delegate: Button {
                    id: delegate

                    width: eventList.width
                    height: contentCol.height + 10

                    z: 100

                    Column {
                        id: contentCol

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 10
                        }

                        height: childrenRect.height + 10

                        spacing: 1

                        Label {
                            id: gradeLa
                            // label for the grade

                            font.bold: true
                            font.pixelSize: hourReplaceSubjectRoomLa.font.pixelSize * 1.5

                            width: parent.width - 10
                            wrapMode: Label.Wrap

                            text: grade
                        }

                        Label {
                            id: hourReplaceSubjectRoomLa
                            // label for the hour, replacement, subject and room

                            width: parent.width - 10
                            height: text === "" ? 0:undefined
                            wrapMode: Label.Wrap

                            text: hour +
                                  (replace === "" ? "": ( " | "+ replace )) +
                                  ( subject === "" ? "": ( " | " + subject )) +
                                  ( room === "" ? "": ( " | " + room ))
                        }

                        Label {
                            id: toTextLa
                            // label for the new room (to) and the additional text (text)

                            width: parent.width - 10
                            height: text === "" ? 0:undefined
                            wrapMode: Label.Wrap

                            font.pixelSize: gradeLa.font.pixelSize
                            font.bold: true

                            text: to +
                                  (model.text === " | " || model.text === "" ? "": ( " | "+ model.text ))
                        }
                    }
                }
            }
        }

        Component {
            id: loadingFormComp
            LoadingForm {}
        }

    }

    Connections {
        target: pageLoader.item
        onRefresh: {
            pageLoader.newSourceComponent = loadingFormComp
            loadTimer.start()
        }
    }

    Timer {
        id: loadTimer
        interval: 500
        running: true
        repeat: false
        onTriggered: {
            root.status = serverConn.getEvents(day)
            pageLoader.newSourceComponent = eventListComp
        }
    }

    Popup {
        id: busyDialog

        parent: overlay

        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)

        height: contentHeight * 1.5
        width: contentWidth * 1.5
        contentHeight: progressCircle.height
        contentWidth: progressCircle.width

        Material.theme: root.Material.theme

        modal: true
        closePolicy: "NoAutoClose"
        focus: true

        ProgressCircle {
            id: progressCircle
            size: 50
            lineWidth: 5
            anchors.centerIn: parent
            colorCircle: Material.theme === Material.Dark ? "#F48FB1":"#E91E63"
            colorBackground: "transparent"
            showBackground: true
            arcBegin: 0
            arcEnd: 360 * serverConn.downloadProgress
            animationDuration: 0
            Label {
                id: progress
                anchors.centerIn: parent
                text: Math.round( serverConn.downloadProgress * 100 ) + "%"
            }
        }
    }


}
