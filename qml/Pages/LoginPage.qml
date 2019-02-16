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

import QtQuick 2.11
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../Components"

Page {
    id: root
    objectName: "LoginPage";

    header: AppToolBar {
        Label {
            text: "Anmeldung"
            anchors.centerIn: parent
            color: "black"
        }
    }

    Grid {
        id: mainGrid
        columns: app.landscape() ? 2:1
        rows: app.landscape() ? 1:2
        spacing: 0

        anchors.fill: parent

        width: parent.width
        height: parent.height

        Column {
            id: logoInfoCol

            width: app.landscape() ? root.width * 0.5:root.width
            height: app.landscape() ? root.height:root.height * 0.3

            Image {
                id: bigLogo
                source: "qrc:/graphics/images/FannyIcon.png"

                anchors {
                    left: parent.left
                    right: parent.right
                }

                height: parent.height * 0.6


                fillMode: Image.PreserveAspectFit
                mipmap: true
                smooth: true
            }

            Label {
                id: infoText
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.8
                height: parent.height * 0.2
                fontSizeMode: Text.Fit;
                minimumPixelSize: 10;
                font.pixelSize: 72
                text: "<html>Bitte melde dich mit den Anmeldedaten der <a href='http://www.fanny-leicht.de/'>Fanny-Webseite</a> an.
                    <a href='http://www.fanny-leicht.de/j34/index.php/aktuelles/vertretungsplan'>Weitere Informationen</a></html>"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }

            }

        }

        Column {
            id: formCol
            spacing: height * 0.01

            width: app.landscape() ? root.width * 0.5:root.width
            height: app.landscape() ? root.height:root.height * 0.7

            property int rowHeight: height / 6 - spacing * 2 > 60 ? 60: height / 6 - spacing * 2

            Rectangle {
                id: spacer
                height: formCol.spacing
                color: "transparent"
            }

            TextField {
                id: tiuname

                anchors {
                    left: parent.left
                    leftMargin: root.width * 0.05
                    right: parent.right
                    rightMargin: root.width * 0.05
                }

                height: formCol.rowHeight

                placeholderText: "Benutzername"
                Keys.onReturnPressed: login(tiuname.text, tipasswd.text, cBperm.checked)
            }


            TextField {
                id: tipasswd
                placeholderText: "Passwort"
                Keys.onReturnPressed: login(tiuname.text, tipasswd.text, cBperm.checked)

                height: formCol.rowHeight

                anchors {
                    left: parent.left
                    leftMargin: root.width * 0.05
                    right: parent.right
                    rightMargin: root.width * 0.05
                }

                MouseArea {
                    id: passwordHideShow
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }
                    width: visibleIcon.width

                    onClicked: {
                        if(state === "visible"){
                            state = "invisible"
                        }
                        else {
                            state = "visible"
                        }
                    }

                    state: "invisible"

                    states: [
                        State {
                            name: "invisible"
                            PropertyChanges {
                                target: visibleIcon
                                scale: 0
                            }
                            PropertyChanges {
                                target: invisibleIcon
                                scale: 1
                            }
                            PropertyChanges {
                                target: tipasswd
                                echoMode: TextInput.Password
                            }
                        },
                        State {
                            name: "visible"
                            PropertyChanges {
                                target: visibleIcon
                                scale: 1
                            }
                            PropertyChanges {
                                target: invisibleIcon
                                scale: 0
                            }
                            PropertyChanges {
                                target: tipasswd
                                echoMode: TextInput.Normal
                            }
                        }
                    ]

                    Image {
                        id: visibleIcon

                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right

                            bottomMargin: parent.height * 0.25
                            topMargin: anchors.bottomMargin
                        }
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        source: "qrc:/graphics/icons/view.png"
                    }

                    Image {
                        id: invisibleIcon

                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right

                            bottomMargin: parent.height * 0.25
                            topMargin: anchors.bottomMargin
                        }
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        source: "qrc:/graphics/icons/hide.png"
                    }
                }
            }

            CheckDelegate {
                id: cBperm
                text: qsTr("Angemeldet bleiben")
                checked: true
                anchors.horizontalCenter: parent.horizontalCenter

                height: formCol.rowHeight
            }

            FancyButton {
                id: loginButton

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    left: parent.left
                    margins: root.width * 0.05
                }

                height: formCol.rowHeight

                text: qsTr("Anmelden")
                enabled: tiuname.length > 0 & tipasswd.length > 0
                onClicked: root.login(tiuname.text, tipasswd.text, cBperm.checked)
            }

            FancyButton {
                id: registerBt

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    left: parent.left
                    margins: window.width * 0.05
                }

                height: formCol.rowHeight

                text: qsTr("Registrieren")
                enabled: true
                onClicked: Qt.openUrlExternally("http://www.fanny-leicht.de/j34/index.php/login?view=registration")
            }

            Label {
                id: laStatus
                text: qsTr("")
                font.pixelSize: height * 0.3
                color: "red"
                anchors.horizontalCenter: parent.horizontalCenter
                height: formCol.rowHeight
            }
        }

        Dialog {
            id: busyDialog
            modal: true
            closePolicy: "NoAutoClose"
            focus: true
            title: "Bitte warten..."
            x: (app.width - width) / 2
            y: (app.height - height) / 2
            width: Math.min(window.width, window.height) / 3 * 2
            height: 150
            contentHeight: contentColumn.height
            Column {
                id: contentColumn
                spacing: 20
                RowLayout {
                    width: parent.width
                    BusyIndicator {
                        id: busyIndicator
                        visible: true
                        x: 22
                        y: 38
                    }

                    Label {
                        width: busyDialog.availableWidth
                        text: "Anmelden..."
                        wrapMode: Label.Wrap
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    function login(username, password, permanent){
        // hide the keyboard
        Qt.inputMethod.hide();
        // open the busy dialog
        busyDialog.open()
        // disable the login button
        loginButton.enabled = false
        // change the text to "Anmelden.."
        loginButton.text = "Anmelden.."

        // trigger the login fucntion of the cpp backend and store the return code
        var ret = serverConn.login(username, password, permanent);

        // the request has finished
        // close the busy dialog
        busyDialog.close()
        // enable the button
        loginButton.enabled = true
        // change the text of the login button back to "Anmelden"
        loginButton.text = "Anmelden"

        // chekc if the login was successfull
        if(ret === 200){
            // if it was -> set the app to inited and set the state of the app to loggedIn
            _cppAppSettings.writeSetting("init", 1);
            app.is_error = false;
            app.state = "loggedIn"
        }
        else{
            // if it wasn't -> set the error label to the error short description of the retuned error code
            laStatus.text = app.getErrorInfo(ret)[1]
        }
    }

}
