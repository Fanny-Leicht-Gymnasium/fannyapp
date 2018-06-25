import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Page {
    anchors.fill: parent

    title: qsTr("Vertretungsplan")

//    Image{
//        source: "qrc:/graphics/chat_background.jpg";
//        height: parent.height
//        width: parent.width
//        fillMode: Image.Tile
//        horizontalAlignment: Image.AlignLeft
//        verticalAlignment: Image.AlignTop
//    }


    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(0, parent.height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4db2b3" }
            GradientStop { position: 1.0; color: "#8f4dae" }
        }
    }

    Label {
        id: laWelcome
        text: "Hier kannst du dir den Vertretungsplan des Fannys anschauen"
        font.pixelSize: 20
        wrapMode: Label.Wrap
        width: window.width / 1.2
        color: "#424753"
        anchors {
            top: parent.top
            topMargin: window.height / 8 - laWelcome.height / 2
            horizontalCenter: parent.horizontalCenter
        }
    }

    Button {
        id:buttToday
        enabled: window.is_error === false
        height: 200
        width: 200
        anchors {
            left: parent.left
            leftMargin: (window.width / 4) -  (buttToday.width / 2)
            verticalCenter: parent.verticalCenter
        }

        onClicked: {
            verificationDialog.day = "sheute"
            verificationDialog.open()
        }
        background: Image {
            id: sheuteImage
            source: "qrc:/graphics/sheute.png"
        }
    }

    Button {
        id: buttTomorrow
        enabled: window.is_error === false
        anchors {
            right: parent.right
            rightMargin: (window.width / 4) -  (buttTomorrow.width / 2)
            verticalCenter: parent.verticalCenter
        }

        onClicked: {
            verificationDialog.day = "smorgen"
            verificationDialog.open()
        }
        background: Image {
            id: smorgenImage
            source: "qrc:/graphics/smorgen.png"
        }
    }

    Rectangle {
        id: buttonsDisabled
        anchors.left: buttToday.left
        anchors.right: buttTomorrow.right
        anchors.top: buttToday.top
        anchors.bottom: buttToday.bottom
        color: "white"
        opacity: 0.7
        visible: window.is_error
    }

    Dialog {
        property string day
        id: verificationDialog
        modal: true
        focus: true
        title: "Bedingung"
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2
        contentHeight: aboutColumn.height
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            busyDialog.open()
            text.visible = false
            console.log("getting file of ", day)
            var ret = _cppServerConn.getDay(day)
            console.log(ret)
            busyDialog.close()
            text.visible = true
            if(ret === "OK"){
                return
            }
            else if(ret === "Ungültige Benutzerdaten."){
                root.StackView.view.pop()
            }
            else {
                error.text = ret
                window.is_error = true
                window.error = ret
                error.visible = true
            }
        }

        Column {
            id: aboutColumn
            spacing: 20
            Label {
                id: text
                visible: true
                width: verificationDialog.availableWidth


                wrapMode: Label.Wrap
                text: "Vertretungsplan, vertraulich, nur zum persönlichen Gebrauch, keine Speicherung!"
            }
        }
    }

    Dialog {
        id: busyDialog
        modal: true
        closePolicy: "NoAutoClose"
        focus: true
        //title: "Please wait..."
        x: (window.width - width) / 2
        y: window.height / 6
        //width: Math.min(window.width, window.height) / 3 * 2
        height: contentHeight * 1.5
        width: contentWidth * 1.5
        contentHeight: busyIndicator.height
        contentWidth: busyIndicator.width
        BusyIndicator {
            id: busyIndicator
            visible: true
            anchors.centerIn: parent
            Label {
                id: progress
                anchors.centerIn: parent
                text: _cppServerConn.getProgress()
            }
            Timer {
                id: refreshTimer
                interval: 1;
                running: busyDialog.visible
                repeat: true
                onTriggered: {
                    var ret = _cppServerConn.getProgress()
                    progress.text = Math.round( ret * 100 ) + "%"
                    progressBar.value = ret
                }
            }
        }
        ProgressBar {
            id: progressBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: busyDialog.height / 1.5
        }
    }
}
