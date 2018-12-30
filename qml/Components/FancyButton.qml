import QtQuick 2.9
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0

Button {
    id: control

    property string image
    property real imageScale: 1

    background: Item {
        id: controlBackgroundContainer

        scale: control.pressed ? 0.8:1

        Behavior on scale {
            PropertyAnimation {
                duration: 100
            }
        }

        RectangularGlow {
            id: effect
            glowRadius: 0.001
            spread: 0.2
            color: "black"
            opacity: 1
            cornerRadius: controlBackground.radius
            anchors.fill: controlBackground
            scale: 0.75
        }

        Rectangle {
            id: controlBackground

            anchors.fill: parent

            radius: height * 0.5

            Image {
                id: buttonIcon
                source: control.image

                anchors.centerIn: parent
                height: parent.height * 0.5
                width: height

                mipmap: true

                fillMode: Image.PreserveAspectFit

                scale: control.imageScale

                Behavior on scale {
                    PropertyAnimation {
                        duration: 100
                    }
                }
            }
        }
    }

}
/*
    background: Image {
        id: smorgenBackground
        source: "qrc:/circle.png"
        height: control.height
        width: height

        scale: control.pressed ? 0.8:1

        Behavior on scale {
            PropertyAnimation {
                duration: 100
            }
        }

        mipmap: true
        smooth: true

        fillMode: Image.PreserveAspectFit

        Image {
            id: smorgenImage
            source: control.image

            anchors.centerIn: parent
            height: parent.height * 0.5
            width: height

            mipmap: true
            smooth: true

            fillMode: Image.PreserveAspectFit

            scale: control.imageScale

            Behavior on scale {
                PropertyAnimation {
                    duration: 100
                }
            }
        }
    }
    */

