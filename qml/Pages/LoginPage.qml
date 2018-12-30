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
        source: "qrc:/favicon.png"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: window.height * 0.01
        height: window.height * 0.2
        fillMode: Image.PreserveAspectFit
        mipmap: true
        smooth: true
    }

    Label {
        id: infoText
        text: "<html>Bitte melde dich mit den Anmeldedaten an, die du für den Vertretungsplan  erhalten hast.
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
            topMargin: window.height * 0.02
            bottomMargin: window.height * 0.2
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
            echoMode: passwordHideShow.state === "visible" ? TextInput.Normal:TextInput.Password
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
                        name: "visible"
                        PropertyChanges {
                            target: visibleIcon
                            scale: 0
                        }
                        PropertyChanges {
                            target: invisibleIcon
                            scale: 1
                        }
                    },
                    State {
                        name: "invisible"
                        PropertyChanges {
                            target: visibleIcon
                            scale: 1
                        }
                        PropertyChanges {
                            target: invisibleIcon
                            scale: 0
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: "*"
                        to: "*"
                        NumberAnimation {
                            properties: "scale,opacity"
                            easing.type: Easing.InOutQuad
                            duration: 200
                        }
                    }
                ]

                Image {
                    id: visibleIcon

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right

                        bottomMargin: parent.height * 0.2
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

        Button {
            id: loginButton
            objectName: "loginButton"
            text: qsTr("Anmelden")
            enabled: tiuname.length > 0 & tipasswd.length > 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.left: parent.left
            anchors.margins: window.width * 0.05
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
            // if it wasn't -> reset the stored credentinals
            _cppAppSettings.writeSetting("permanent", "0")
            _cppAppSettings.writeSetting("username", "")
            _cppAppSettings.writeSetting("password", "")
            // and set the error label to the error short description of the retuned error code
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
