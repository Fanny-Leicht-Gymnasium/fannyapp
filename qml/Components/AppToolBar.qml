import QtQuick 2.6
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

Item {
    id: control
    height: 50
    property bool showErrorBar: true

    RectangularGlow {
        id: toolBarEffect
        glowRadius: 3
        spread: 0.2
        color: "black"
        opacity: 0.3
        anchors.fill: toolBar
    }

    Rectangle {
        id: toolBar
        color: "white"
        anchors.fill: parent

//        anchors {
//            top: parent.top
//            left: parent.left
//            right: parent.right
//            topMargin: -60
//        }

        Rectangle {
            id: errorField
            width: parent.width
            height: 30
            enabled: app.is_error & app.state !== "notLoggedIn" & control.showErrorBar
            anchors.top: parent.bottom

            color: "red"
            onEnabledChanged: {
                if(enabled){
                    toolBar.state = 'moveIn'
                }
                else {
                    toolBar.state = 'moveOut'
                }
            }

            MouseArea { anchors.fill: parent; onClicked: {
                    toolBar.state = 'moveOut'

                    console.log("clicked")
                }
            }

            Text {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                id: errorText
                font.family: "Helvetica"
                color: "White"
                font.pointSize: 8
                visible: parent.height !== 0
                text: app.error
            }
        }

        states: [
            State {
                name: "moveOut"
                PropertyChanges { target: errorField; height: 0 }
            },
            State {
                name: "moveIn"
                PropertyChanges { target: errorField; height: 30 }
            }
        ]

        transitions: [
            Transition {
                to: "moveOut"
                NumberAnimation { properties: "height"; easing.type: Easing.InOutQuad; duration: 200 }
            },
            Transition {
                to: "moveIn"
                NumberAnimation { properties: "height"; easing.type: Easing.InOutQuad; duration: 200 }
            }
        ]
    }
}
