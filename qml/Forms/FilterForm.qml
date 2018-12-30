import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import Backend 1.0

import "../Components"

Page {
    id: root

    property bool teacherMode: _cppAppSettings.loadSetting("teacherMode") === "true"

    title: "Vertretungsplan Filter"

    signal opened()

    onOpened: {
        console.log("Filter Form opened")
    }

    Dialog {
        id: filterDialog

        signal finished(string grade, string classletter, string teacherShortcut)

        property bool teacherMode: _cppAppSettings.loadSetting("teacherMode") === "true"

        onFinished: {
            if(_cppAppSettings.loadSetting("teacherMode") === "true"){
                contactView.model.append(teacherShortcut, "", "t");
            }
            else {
                if(parseInt(grade) > 10 || classletter === "alle"){
                    classletter = ""
                }

                contactView.model.append(grade, classletter, "s")
            }
        }

        function createContact() {
            form.grade.value = 5
            form.classLetter.currentIndex = 0
            form.teacherShortcut.text = ""

            filterDialog.title = qsTr("Filter hinzufügen");
            filterDialog.open();
        }

        x: ( parent.width - width ) / 2
        y: ( parent.height - height ) / 2

        focus: true
        modal: true
        title: qsTr("Add Contact")
        standardButtons: Dialog.Ok | Dialog.Cancel

        contentItem: GridLayout {
                id: form
                property alias grade: gradeSb
                property alias classLetter: classLetterCb
                property alias teacherShortcut: shortcutTf
                property int minimumInputSize: 120

                rows: 4
                columns: 2

                Label {
                    text: qsTr("Stufe")
                    Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                    visible: !filterDialog.teacherMode
                }

                SpinBox {
                    id: gradeSb
                    focus: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: form.minimumInputSize
                    Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                    from: 5
                    to: 12
                    stepSize: 1
                    value: 5
                    visible: !filterDialog.teacherMode
                }

                Label {
                    text: qsTr("Klasse")
                    Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                    visible: !filterDialog.teacherMode
                }

                ComboBox {
                    id: classLetterCb
                    Layout.fillWidth: true
                    Layout.minimumWidth: form.minimumInputSize
                    Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline
                    model: ["a", "b", "c", "d", "e", "alle"]
                    enabled: gradeSb.value < 11
                    visible: !filterDialog.teacherMode
                }

                Label {
                    text: qsTr("Kürzel")
                    Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

                    visible: filterDialog.teacherMode
                }

                TextField {
                    id: shortcutTf
                    focus: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: form.minimumInputSize
                    Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

                    visible: filterDialog.teacherMode
                }
            }

        onAccepted: finished(form.grade.value, form.classLetter.currentText, form.teacherShortcut.text)
    }

    ListView {
        id: contactView

        anchors.fill: parent

        width: 320
        height: 480

        focus: true

        delegate: ItemDelegate {
            id: delegate

            width: contactView.width
            height: 0

            Component.onCompleted: {
                delegate.height = 50
            }

            text: grade + classLetter
            font.pixelSize: height * 0.4

            enabled: root.teacherMode ? role === "t":role === "s"

            Rectangle {

                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                height: 1
                width: parent.width

                color: "lightgrey"
            }

            Behavior on height {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }


            NumberAnimation {
                id: deleteAnimation
                target: delegate
                property: "height"
                duration: 500
                from: delegate.height
                to: 0
                easing.type: Easing.InOutQuad
                onRunningChanged: {
                    if(!running){
                        contactView.model.remove(index)
                    }
                }
            }

            Button {
                id: deleteButton

                anchors {
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                height: parent.height * 0.6
                width: height

                scale: pressed ? 0.8:1

                onClicked: {
                    deleteAnimation.start()
                }

                background: Image {
                    source: "/graphics/icons/delete.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }

                Behavior on scale {
                    PropertyAnimation {
                        duration: 100
                    }
                }
            }
        }

        model: FilterModel {

        }

        ScrollBar.vertical: ScrollBar { }
    }

    FancyButton {

        highlighted: true

        anchors {
            margins: 10
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        imageScale: 0

        height: 50
        width: height

        onClicked: {
            filterDialog.createContact()
        }

        Label {
            anchors.centerIn: parent
            font.pixelSize: parent.height * 0.6
            text: "+"
        }
    }
}
