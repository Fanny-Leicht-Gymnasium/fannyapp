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

import QtQuick 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

import "../Components"

Page {
    id: root
    objectName: "LoginPage";

    header: AppToolBar {
        Label {
            text: "Anmeldung"
            anchors.centerIn: parent
            color: app.style.style.textColor
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
                smooth: true
            }

            Label {
                id: infoText

                anchors.horizontalCenter: parent.horizontalCenter

                width: parent.width * 0.8
                height: parent.height * 0.2

                horizontalAlignment: Text.AlignHCenter

                fontSizeMode: Text.Fit;
                minimumPixelSize: 10;
                font.pixelSize: 72
                wrapMode: Text.Wrap

                text: "<html>Bitte melde dich mit den Anmeldedaten der <a href='http://www.fanny-leicht.de/'>Fanny-Webseite</a> an.
                    <a href='http://www.fanny-leicht.de/j34/index.php/aktuelles/vertretungsplan'>Weitere Informationen</a></html>"

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }

            }

        }

        Column {
            id: formCol
            spacing: height * 0.02

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
                Keys.onReturnPressed: login(tiuname.text, tipasswd.text)
            }

            TextField {
                id: tipasswd
                placeholderText: "Passwort"
                Keys.onReturnPressed: login(tiuname.text, tipasswd.text)

                height: formCol.rowHeight

                anchors {
                    left: parent.left
                    leftMargin: root.width * 0.05
                    right: parent.right
                    rightMargin: root.width * 0.05
                }

                CompatibleToolButton{
                    id: passwordHideShow
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }

                    icon.color: app.style.style.textColor

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
                                target: passwordHideShow
                                icon.name: "hide"
                                text: "show"
                            }

                            PropertyChanges {
                                target: tipasswd
                                echoMode: TextInput.Password
                            }
                        },
                        State {
                            name: "visible"
                            PropertyChanges {
                                target: passwordHideShow
                                icon.name: "view"
                                text: "hide"
                            }
                            PropertyChanges {
                                target: tipasswd
                                echoMode: TextInput.Normal
                            }
                        }
                    ]
                }

            }

            Label {
                id: laStatus

                anchors.horizontalCenter: parent.horizontalCenter

                height: formCol.rowHeight * 0.5
                width: parent.width

                fontSizeMode: Text.Fit
                font.pixelSize: height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: "red"

                text: qsTr("")
            }

            FancyButton {
                id: loginButton

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    left: parent.left
                    margins: root.width * 0.05
                }

                height: formCol.rowHeight

                enabled: tiuname.length > 0 & tipasswd.length > 0

                text: qsTr("Anmelden")

                onClicked: root.login(tiuname.text, tipasswd.text)
            }

            Label {
                id: registerAndForgotLa

                anchors.horizontalCenter: parent.horizontalCenter

                height: formCol.rowHeight

                verticalAlignment: Text.AlignVCenter

                font.pixelSize: height * 0.3
                horizontalAlignment: Text.AlignHCenter

                text: "<html><a href=\"http://www.fanny-leicht.de/j34/index.php/login?view=registration\">Registrieren</a><br><a href=\"http://www.fanny-leicht.de/j34/index.php/login?view=reset\">Passwort vergessen?</a><br><a href=\"http://www.fanny-leicht.de/j34/index.php/login?view=remind\">Benutzername vergessen?</a>"

                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }

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
            Material.theme: _cppAppSettings.loadSetting("theme") === "Dark" ? Material.Dark:Material.Light

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

    function login(username, password){
        // hide the keyboard
        Qt.inputMethod.hide();
        // open the busy dialog
        busyDialog.open()
        // disable the login button
        loginButton.enabled = false
        // change the text to "Anmelden.."
        loginButton.text = "Anmelden.."

        // trigger the login fucntion of the cpp backend and store the return code
        var ret = serverConn.login(username, password, true);

        // the request has finished
        // close the busy dialog
        busyDialog.close()
        // enable the button
        loginButton.enabled = true
        // change the text of the login button back to "Anmelden"
        loginButton.text = "Anmelden"

        // chekc if the login was not successfull
        if(ret !== 200){
            // set the error label to the error short description of the retuned error code
            laStatus.text = app.getErrorInfo(ret)[1]
        }
    }
}
