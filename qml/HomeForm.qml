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


//    LinearGradient {
//        anchors.fill: parent
//        start: Qt.point(0, 0)
//        end: Qt.point(0, parent.height)
//        gradient: Gradient {
//            GradientStop { position: 0.0; color: "#4db2b3" }
//            GradientStop { position: 1.0; color: "#8f4dae" }
//        }
//    }

    Label {
        id: laWelcome
        text: "Hier kannst du dir den Vertretungsplan des Fannys anschauen"
        font.pixelSize: 20
        wrapMode: Label.Wrap
        width: window.width / 1.2
        color: window.text_color
        anchors {
            top: parent.top
            topMargin: window.height / 8 - laWelcome.height / 2
            horizontalCenter: parent.horizontalCenter
        }
    }

    Button {
        id:buttToday
        enabled: window.is_error === false
        anchors {
            left: parent.left
            leftMargin: (window.width / 4) -  (buttToday.width / 2)
            verticalCenter: parent.verticalCenter
        }

        onClicked: {
            verificationDialog.day = "sheute"
            verificationDialog.open()
        }

        onPressed: sheuteImage.scale = 0.9
        onReleased: sheuteImage.scale = 1.0

        background: Image {
            id: sheuteImage
            source: "qrc:/graphics/sheute.png"

            Behavior on scale {
                PropertyAnimation {
                    duration: 100
                }
            }
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

        onPressed: smorgenImage.scale = 0.9
        onReleased: smorgenImage.scale = 1.0

        background: Image {
            id: smorgenImage
            source: "qrc:/graphics/smorgen.png"

            Behavior on scale {
                PropertyAnimation {
                    duration: 100
                }
            }
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
            _cppServerConn.updateProgress(0,100)
            busyDialog.open()
            text.visible = false
            var ret = _cppServerConn.getDay(day)
            progressCircle.arcEnd = 36000
            progress.text = "100%"
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
        contentHeight: progressCircle.height
        contentWidth: progressCircle.width

        ProgressCircle {
            id: progressCircle
            size: 50
            lineWidth: 5
            anchors.centerIn: parent
            colorCircle: "#FF3333"
            colorBackground: "#E6E6E6"
             showBackground: true
             arcBegin: 0
             arcEnd: 0
             Label {
                 id: progress
                 anchors.centerIn: parent
                 text: "0%"
             }
             Timer {
                 id: refreshTimer
                 interval: 1;
                 running: busyDialog.visible
                 repeat: true
                 onTriggered: {
                     var ret = _cppServerConn.getProgress()

                     progressCircle.arcEnd = 360 * ret * 1.2
                     progress.text = Math.round( ret * 100 ) + "%"
                 }
             }
        }
    }
}
