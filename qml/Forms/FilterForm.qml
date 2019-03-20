/*
    Fannyapp - Application to view the cover plan of the Fanny-Leicht-Gymnasium ins Stuttgart Vaihingen, Germany
    Copyright (C) 2019  Itsblue Development <development@itsblue.de>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.impl 2.0
import QtQuick.Templates 2.0 as T
import Backend 1.0

import "../Components"

Page {
    id: root

    property bool teacherMode: _cppAppSettings.loadSetting("teacherMode") === "true"
    property bool locked: false

    title: "Vertretungsplan Filter"

    signal opened()

    onOpened: {}

    Material.theme: app.style.style.nameMaterialStyle === "Dark" ? Material.Dark:Material.Light


    Dialog {
        id: filterDialog

        signal finished(string grade, string classletter, string teacherShortcut)

        property bool teacherMode: _cppAppSettings.loadSetting("teacherMode") === "true"

        Material.theme: app.style.style.nameMaterialStyle === "Dark" ? Material.Dark:Material.Light

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

                    popup: T.Popup {
                        y: classLetterCb.editable ? classLetterCb.height - 5 : 0
                        width: classLetterCb.width
                        height: Math.min(contentItem.implicitHeight, app.height - topMargin - bottomMargin)
                        transformOrigin: Item.Top
                        topMargin: 12
                        bottomMargin: 12

                        Material.theme: classLetterCb.Material.theme
                        Material.accent: classLetterCb.Material.accent
                        Material.primary: classLetterCb.Material.primary

                        enter: Transition {
                            // grow_fade_in
                            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
                            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
                        }

                        exit: Transition {
                            // shrink_fade_out
                            NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
                            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
                        }

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: classLetterCb.delegateModel
                            currentIndex: classLetterCb.highlightedIndex
                            highlightMoveDuration: 0

                            T.ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            radius: 2
                            color: classLetterCb.Material.dialogColor

                            layer.enabled: classLetterCb.enabled
//                            layer.effect: ElevationEffect {
//                                elevation: 8
//                            }
                        }
                    }

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
            font.pixelSize: delegate.height * 0.4


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

        size: 50

        onClicked: {
            filterDialog.createContact()
        }

        Label {
            anchors.centerIn: parent
            font.pixelSize: parent.height * 0.6
            text: "+"
            color: app.style.style.textColor
        }
    }
}
