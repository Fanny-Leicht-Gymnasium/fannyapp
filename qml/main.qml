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
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

import Backend 1.0

import "./Components"
import "./Forms"
import "./Pages"

ApplicationWindow {
    id: window
    visible: true
    width: 540
    height: 960

    Item {
        id: app

        anchors.fill: parent

        property bool is_error
        property string error

        property string textColor: "black" // "#424753"
        property string backgroundColor: "white"
        property string toolbarColor: "#312f38"

        property QtObject style: style

        state: serverConn.state

        states: [
            State {
                name: "notLoggedIn"
                PropertyChanges {
                    target: mainStack
                    currPage: loginPage
                }
            },

            State {
                name: "loggedIn"
                PropertyChanges {
                    target: mainStack
                    currPage: mainPage
                }
            }
        ]

        ServerConn {
            id: serverConn

            onStateChanged: {
                app.state = newState
            }
        }

        AppStyle {
            id: style
        }

        Material.theme: app.style.style.nameMaterialStyle === "Dark" ? Material.Dark:Material.Light

        StackView {
            id: mainStack

            property var currPage

            anchors.fill: parent

            onCurrPageChanged: {
                mainStack.replace(currPage)
            }

            Component {
                id: loginPage
                LoginPage {
                }
            }

            Component {
                id: mainPage
                MainPage {
                }
            }
        }

        FontLoader {
            id: fontAwesome
            name: "fontawesome"
            source: "qrc:/fonts/fontawesome-webfont.ttf"
        }

        function getErrorInfo(errorCode) {

            var infoLevel
            // 0 - ok
            // 1 - info
            // 2 - warn
            // 3 - error

            var errorString
            var errorDescription
            var errorButtonOption = ""

            switch(errorCode) {
            case 0:
                infoLevel = 3
                errorString = "Keine Verbindung zum Server"
                errorDescription = "Bitte überprüfe deine Internetverbindung und versuche es erneut."
                break
            case 401:
                infoLevel = 3
                errorString = "Ungültige Zugangsdaten"
                errorDescription = "Der Server hat den Zugang verweigert, bitte überprüfe deine Zugangsdaten und versuche es erneut."
                break
            case 403:
                infoLevel = 3
                errorString = "Account nicht freigegeben"
                errorDescription = "Die Anmeldedaten waren korrekt, der Account ist jedoch nicht freigegeben."
                break
            case 500:
                infoLevel = 3
                errorString = "Interner Server Fehler"
                errorDescription = "Scheinbar kann der Server die Anfrage im Moment nicht verarbeiten, bitte versuche es später erneut."
                break
            case 900:
                infoLevel = 2
                errorString = "Verarbeitungsfehler"
                errorDescription = "Die Daten, die vom Server übertragen wurden, konnten nicht richtig verarbeitet werden, bitte versuche es später erneut."
                errorButtonOption = "Als Pdf ansehen"
                break
            case 901:
                infoLevel = 1
                errorString = "Keine Daten"
                errorDescription = "Es liegen keine aktuellen Daten vor."
                break
            case 902:
                infoLevel = 1
                errorString = "Alte Daten"
                errorDescription = "Es konnte keine Verbindung zum Server hergestellt werden, aber es sind noch alte Daten gespeichert."
                break
            case 903:
                infoLevel = 1
                errorString = "Ungültiger Aufruf"
                errorDescription = "Die aufgerufene Funktion ist momentan nicht verfügbar, bitte versuche es später erneut."
                break
            case 904:
                infoLevel = 3
                errorString = "Inkompatible API"
                errorDescription = "Die Version der API auf dem Server ist zu neu und kann daher nicht verarbeitet werden. Bitte aktualisiere die App auf die aktuellste Version."
                errorButtonOption = "Als Pdf ansehen"
                break
            case 905:
                infoLevel = 3
                errorString = "Interner Speicherfehler"
                errorDescription = "Die Pdf-Datei konnte nicht gespeichert werden."
                break
            default:
                infoLevel = 3
                errorString = "Unerwarteter Fehler ("+errorCode+")"
                errorDescription = "Unbekannter Fehler bei der Verbindung mit dem Server."
            }

            return([infoLevel, errorString, errorDescription, errorButtonOption])
        }

        function landscape(){
            return(app.width > app.height)
        }
    }
}
