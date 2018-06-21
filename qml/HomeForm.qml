import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    anchors.fill: parent

    title: qsTr("Vertretungsplan")

    Label {
        id: laWelcome
        text: "Hier kannst du dir den Vertretungsplan des Fannys anschauen"
        font.pixelSize: 20
        wrapMode: Label.Wrap
        width: window.width / 1.2

        anchors {
            top: parent.top
            topMargin: window.height / 8 - laWelcome.height / 2
            horizontalCenter: parent.horizontalCenter
        }
    }

    Button {
        id:buttToday
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
        }
    }

}
