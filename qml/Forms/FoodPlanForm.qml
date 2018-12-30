import QtQuick 2.9
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "../Components"

Page {
    id:root
    //anchors.fill: parent
    property bool cookplanChanged
    title: qsTr("Speiseplan")
    property string icon: "qrc:/graphics/images/TreffpunktFannyLogo.png"
    property string link: "http://www.treffpunkt-fanny.de"
    property int status: -1

    signal opened()

    onOpened: {
        console.warn("foodplan opened")
    }

//    Image{
//        source: "qrc:/graphics/chat_background.jpg";
//        height: parent.height
//        width: parent.width
//        fillMode: Image.Tile
//        horizontalAlignment: Image.AlignLeft
//        verticalAlignment: Image.AlignTop
//    }
//    LinearGradient {
//        anchors.fill: parent
//        start: Qt.point(0, 0)
//        end: Qt.point(0, parent.height)
//        gradient: Gradient {
//            GradientStop { position: 0.0; color: "#4db2b3" }
//            GradientStop { position: 1.0; color: "#8f4dae" }
//        }
//    }

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