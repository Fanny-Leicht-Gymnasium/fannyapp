import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import "../Components"

Page {
    id: root

    property string day

    title: qsTr("Vertretungsplan")

    property int status: -1

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
            root.status = serverConn.getEvents(day)
            pageLoader.newSource = "../Components/EventView.qml"
        }
    }
}
