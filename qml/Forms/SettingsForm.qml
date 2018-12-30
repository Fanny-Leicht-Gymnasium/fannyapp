import QtQuick 2.0
import QtQuick.Controls 2.4

import "../Components"

Page {
    id: root

    title: "Einstellungen"

    signal opened()

    onOpened: {
        console.log("Settings Form opened")

        var filters = _cppAppSettings.readFiltersQml()
    }

    Column {
        id: settingsCol

        anchors.fill: parent

        SettingsDelegate {
            width: parent.width

            onClicked: {
                formStack.push(filterForm)
            }

            title: "Filter"
            description: "Wähle die Klassen(stufen) bzw. Lehrerkürzel aus, für die du den Vertretungsplan ansehen möchtest"
        }

        SwitchDelegate {
            width: parent.width
            height: 10 + shortDescription.height + 2 + longDescription.height + 10

            checked: _cppAppSettings.loadSetting("teacherMode") === "true"

            onCheckedChanged: {
                _cppAppSettings.writeSetting("teacherMode", checked)
            }

            Label {
                id: shortDescription

                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 10
                }

                font.pixelSize: longDescription.font.pixelSize * 1.4

                text: "Lehrermodus"

            }

            Label {
                id: longDescription

                anchors {
                    top: shortDescription.bottom
                    topMargin: 2
                    left: parent.left
                    leftMargin: 10
                }

                width: parent.width * 0.9

                wrapMode: Label.Wrap

                text: "Lehrermodus aktivieren"
            }

            indicator: Rectangle {
                property bool checked: parent.checked
                property bool down: parent.down
                property int set_height: parent.font.pixelSize * 1.4
                implicitWidth: set_height * 1.84
                implicitHeight: set_height
                x: parent.width - width - parent.rightPadding
                y: parent.height / 2 - height / 2
                radius: implicitHeight * 0.5
                color: parent.checked ? "#17a81a" : "transparent"
                border.color: parent.checked ? "#17a81a" : "#cccccc"
                Behavior on color{
                    ColorAnimation{
                        duration: 200
                    }
                }

                Rectangle {
                    x: parent.checked ? parent.width - width : 0
                    width: parent.height
                    height: parent.height
                    radius: height * 0.5
                    color: parent.down ? "#cccccc" : "#ffffff"
                    border.color: parent.checked ? (parent.down ? "#17a81a" : "#21be2b") : "#999999"
                    Behavior on x{
                        NumberAnimation {
                            property: "x"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }
}