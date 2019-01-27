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

    Image {
        id: bigLogo
        source: "qrc:/graphics/images/FannyIcon.png"

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: window.height * 0.01
        }

        height: window.height * 0.2
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true
    }

    Label {
        id: infoText
        text: "<html>Bitte melde dich mit den Anmeldedaten der Fanny-Webseite an.
                <a href='http://www.fanny-leicht.de/j34/index.php/aktuelles/vertretungsplan'>Weitere Informationen</a></html>"
        wrapMode: Text.Wrap
        onLinkActivated: {
            Qt.openUrlExternally(link)
        }

        anchors {
            top: bigLogo.bottom
            left: parent.left
            right: parent.right
            leftMargin: window.width * 0.05
            rightMargin: window.width * 0.05
        }
    }

    Column {
        spacing: ( height - 100 ) * 0.1

        anchors {
            left: parent.left
            right: parent.right
            top: infoText.bottom
            bottom: parent.bottom
            topMargin: root.height * 0.02
            bottomMargin: root.height * 0.2
        }

        TextField {
            id: tiuname
            placeholderText: "Benutzername"
            Keys.onReturnPressed: login(tiuname.text, tipasswd.text, cBperm.checked)

            anchors {
                left: parent.left
                leftMargin: root.width * 0.05
                right: parent.right
                rightMargin: root.width * 0.05
            }
        }


        TextField {
            id: tipasswd
            placeholderText: "Passwort"
            Keys.onReturnPressed: login(tiuname.text, tipasswd.text, cBperm.checked)

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
        }

        FancyButton {
            id: loginButton

            anchors {
                horizontalCenter: parent.horizontalCenter
                left: parent.left
                margins: window.width * 0.05
            }

            text: qsTr("Anmelden")
            enabled: tiuname.length > 0 & tipasswd.length > 0
            onClicked: login(tiuname.text, tipasswd.text, cBperm.checked)
        }
        Label {
            id: laStatus
            text: qsTr("")
            font.pixelSize: 20
            color: "red"
            anchors.horizontalCenter: parent.horizontalCenter
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

        console.log(username, password, permanent)

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
