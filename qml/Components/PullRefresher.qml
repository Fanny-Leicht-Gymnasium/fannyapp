/*
    blueROCK - for digital rock
    Copyright (C) 2019  Dorian Zedler

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.9
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

Item {
    id: control

    state: "idle"

    property var target                         // targeted ListView

    property bool autoConfigureTarget: true     // should the target be automaticaly be configured?

    property int postRefreshDelay: 1000         // delay after reload funcion has finished
    property int preRefreshDelay: 1000          // delay before reload funcion is called

    property int refreshPosition: height * 1.2  // position of the item when refreshing
    property int dragOutPosition: height * 1.8  // maximum drag out

    property double dragRefreshPositionMultiplier: 0.5 // position of the item when starting to refresh

    property color backgroundColor: "white"     // color for the pre-defined background
    property color pullIndicatorColor: "black"  // color for the pre-defined pull indicator
    //property color busyIndicatorColor: "pink"   // color for the pre-defined busy indicator

    readonly property double dragProgress: Math.min( userPosition / dragOutPosition, 1)

    property Component background: Item {
        RectangularGlow {
            anchors.fill: backgroundRe

            scale: 0.8 * backgroundRe.scale
            cornerRadius: backgroundRe.radius
            color: "black"

            glowRadius: 0.001
            spread: 0.2
        }

        Rectangle {
            id: backgroundRe

            anchors.fill: parent

            radius: width * 0.5
            color: control.backgroundColor
        }
    }
    property Component busyIndicator: BusyIndicator { running: true }
    property Component pullIndicator: Canvas {

        property double drawProgress: control.dragProgress

        rotation: drawProgress > control.dragRefreshPositionMultiplier ? 180:0

        onDrawProgressChanged: {
            requestPaint()
        }

        onPaint: {
            var ctx = getContext("2d");

            var topMargin = height * 0.1
            var bottomMargin = topMargin
            var rightMargin = 0
            var leftMargin = 0

            var arrowHeight = height - topMargin - bottomMargin

            var peakHeight = arrowHeight * 0.35
            var peakWidth = peakHeight

            var lineWidth = 2

            var progress = drawProgress * 1 / control.dragRefreshPositionMultiplier > 1 ? 1 : drawProgress * 1 / control.dragRefreshPositionMultiplier
            // modify all values to math the progress

            arrowHeight = arrowHeight * progress
            if(progress > 0.3){
                peakHeight = peakHeight * (progress - 0.3) * 1/0.7
                peakWidth = peakWidth * (progress - 0.3) * 1/0.7
            }
            else {
                peakHeight = 0
                peakWidth = 0
            }

            // clear canvas
            ctx.reset()

            ctx.lineWidth = lineWidth;
            ctx.strokeStyle = control.pullIndicatorColor;

            // middle line
            ctx.moveTo(width/2, topMargin);
            ctx.lineTo(width/2, arrowHeight + topMargin);

            // right line
            ctx.moveTo(width/2 - lineWidth * 0.3, arrowHeight + topMargin);
            ctx.lineTo(width/2 + peakWidth,arrowHeight + topMargin - peakHeight);
            // left line
            ctx.moveTo(width/2 + lineWidth * 0.3, arrowHeight + topMargin);
            ctx.lineTo(width/2 - peakWidth,arrowHeight + topMargin - peakHeight);

            ctx.stroke();
        }

        Behavior on rotation {
            NumberAnimation {
                duration: 100
            }
        }

    }

    signal refreshRequested

    // internal properties
    property int minimumPosition: 0
    property int maximumPosition: 0
    property int userPosition: 0
    property int position: Math.max( minimumPosition, Math.min(maximumPosition, userPosition))

    height: 50
    width: height

    Component.onCompleted: {
        if(control.autoConfigureTarget){
            target.boundsBehavior = Flickable.DragOverBounds
            target.boundsMovement = Flickable.StopAtBounds
        }
    }

    function refresh() {
        control.refreshRequested()
        postRefreshTimer.start()
    }

    anchors {
        top: control.target.top
        horizontalCenter: control.target.horizontalCenter
        topMargin: control.position - height
    }

    Connections {
        target: control.target
        onDragEnded: {
            if(userPosition >= control.dragOutPosition * control.dragRefreshPositionMultiplier){
                control.state = "refreshing"
                preRefreshTimer.start()
            }
        }
    }

    Loader {
        id: backgroundLd

        anchors.fill: parent

        sourceComponent: control.background
    }

    Loader {
        id: pullIndicatorLd

        anchors.centerIn: parent

        height: parent.height * 0.6
        width: height

        rotation: 180

        sourceComponent: control.pullIndicator
    }

    Loader {
        id: busyIndicatorLd

        anchors.centerIn: parent

        height: parent.height * 0.7
        width: height

        opacity: 0

        sourceComponent: control.busyIndicator
    }

    Timer {
        id: preRefreshTimer
        interval: control.preRefreshDelay <= 0 ? 1:control.preRefreshDelay
        running: false
        repeat: false
        onTriggered: {
            control.refresh()
        }
    }

    Timer {
        id: postRefreshTimer
        interval: control.postRefreshDelay <= 0 ? 1:control.postRefreshDelay
        running: false
        repeat: false
        onTriggered: {
            control.state = "hidden"
        }
    }

    Behavior on minimumPosition {
        enabled: !control.target.dragging && state !== "idle"
        NumberAnimation {
            duration: 100
        }
    }

    states: [
        State {
            name: "idle"

            PropertyChanges {
                target: control
                minimumPosition: userPosition > maximumPosition ? maximumPosition:userPosition
                userPosition: -1 / (Math.abs( (target.verticalOvershoot > 0 ? 0:target.verticalOvershoot) * 0.001 + 0.003 ) + 1 / control.dragOutPosition * 0.001) + control.dragOutPosition // Math.abs( target.verticalOvershoot )
                maximumPosition: control.dragOutPosition
            }

            PropertyChanges {
                target: pullIndicatorLd
                rotation: 0
            }
        },
        State {
            name: "refreshing"
            PropertyChanges {
                target: control
                minimumPosition: control.refreshPosition
                userPosition: 0
                maximumPosition: control.refreshPosition

            }

            PropertyChanges {
                target: pullIndicatorLd
                opacity: 0
            }

            PropertyChanges {
                target: busyIndicatorLd
                opacity: 1
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: control
                minimumPosition: control.refreshPosition
                userPosition: 0
                maximumPosition: control.refreshPosition
                scale: 0
            }

            PropertyChanges {
                target: pullIndicatorLd
                opacity: 0
            }

            PropertyChanges {
                target: busyIndicatorLd
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                duration: 100
                properties: "rotation, opacity"
            }
        },

        Transition {
            from: "refreshing"
            to: "hidden"

            PauseAnimation {
                duration: 200
            }

            NumberAnimation {
                duration: 200
                properties: "scale"
            }

            onRunningChanged: {
                if(control.state === "hidden" && !running){
                    control.state = "idle"
                }
            }
        },

        Transition {
            from: "hidden"
            to: "idle"
        }

    ]

}
