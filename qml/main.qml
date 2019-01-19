import QtQuick 2.9
import QtQuick.Controls 2.2

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

        StackView {
            id: mainStack

            property var currPage

            anchors.fill: parent

            onCurrPageChanged: {
                mainStack.replace(currPage)
            }

            //initialItem: mainPage

            Component {
                id: loginPage
                LoginPage {}
            }

            Component {
                id: mainPage
                MainPage {}
            }
        }

        function getErrorInfo(errorCode) {

            var infoLevel
            // 0 - ok
            // 1 - info
            // 2 - error

            var errorString
            var errorDescription

            switch(errorCode) {
            case 0:
                infoLevel = 2
                errorString = "Keine Verbindung zum Server"
                errorDescription = "Bitte überprüfe deine Internetverbindung und versuche es erneut."
                break
            case 401:
                infoLevel = 2
                errorString = "Ungültige Zugangsdaten"
                errorDescription = "Der Server hat den Zugang verweigert, bitte überprüfe deine Zugangsdaten und versuche es erneut"
                break
            case 500:
                infoLevel = 2
                errorString = "Interner Server Fehler"
                errorDescription = "Scheinbar kann der Server die Anfrage im Moment nicht verarbeiten, bitte versuche es später erneut."
                break
            case 900:
                infoLevel = 2
                errorString = "Interner Verarbeitungsfehler"
                errorDescription = "Die Daten, die vom Server übertragen wurden, konnten nicht richtig verarbeitet werden, bitte versuche es später erneut."
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
            default:
                infoLevel = 2
                errorString = "Unerwarteter Fehler ("+errorCode+")"
                errorDescription = "Unbekannter Fehler bei der Verbindung mit dem Server."
            }

            return([infoLevel, errorString, errorDescription])
        }

        function landscape(){
            return(app.width > app.height)
        }
    }
}
