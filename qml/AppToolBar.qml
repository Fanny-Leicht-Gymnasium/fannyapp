import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

ToolBar {
    id: toolBar
    property bool showErrorBar: true
    Material.theme: Material.Light
    Rectangle {
        id: errorField
        width: parent.width
        height: 30
        enabled: window.is_error & stackView.currentItem.objectName !== "LoginPage" & showErrorBar
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
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: ( parent.height / 2 ) - ( height / 2 )
            }

            id: errorText
            font.family: "Helvetica"
            color: "White"
            font.pointSize: 8

            text: window.error
        }
    }

    states: [
            State {
                name: "moveOut"
                PropertyChanges { target: errorField; height: 0 }
                PropertyChanges { target: errorText; height: 0 }
            },
            State {
                name: "moveIn"
                PropertyChanges { target: errorField; height: 30 }
                PropertyChanges { target: errorText; height: 0 }
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
