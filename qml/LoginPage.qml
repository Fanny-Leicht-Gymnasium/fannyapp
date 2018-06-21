import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

Page {
    id: root
    anchors.fill: parent
    objectName: "LoginPage";

    header: AppToolBar {

    }

    Image {
        id: bigLogo
        source: "favicon.png"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: window.height * 0.01
        height: window.height * 0.2
        fillMode: Image.PreserveAspectFit
    }

    ColumnLayout {

        spacing: 40
        width: parent.width
        anchors.fill: parent
        anchors.topMargin: bigLogo.height + window.height * 0.01
        anchors.bottomMargin: window.height * 0.2

        TextField {
            id: tiuname
            placeholderText: "Username"
            anchors.horizontalCenter: parent.horizontalCenter
            Keys.onReturnPressed: login(tiuname.text, tipasswd.text, cBperm.checked)
            anchors.left: parent.left
            anchors.margins: window.width * 0.05

        }


        TextField {
            id: tipasswd
            echoMode: TextInput.Password
            placeholderText: "Password"
            anchors.horizontalCenter: parent.horizontalCenter
            Keys.onReturnPressed: login(tiuname.text, tipasswd.text, cBperm.checked)
            anchors.left: parent.left
            anchors.margins: window.width * 0.05
        }

        CheckDelegate {
            id: cBperm
            text: qsTr("Stay logged in")
            checked: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            id: loginButton
            objectName: "loginButton"
            text: qsTr("Login")
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
        Qt.inputMethod.hide();
        busyDialog.open()
        loginButton.enabled = false
        loginButton.text = "Loggin in.."
        console.log(username, password, permanent)
        var ret = _cppServerConn.login(username, password, permanent);
        busyDialog.close()
        loginButton.enabled = true
        loginButton.text = "Login"
        if(ret === "OK"){
            _cppAppSettings.writeSetting("init", 1);
            window.is_error = false;
            root.StackView.view.push("MainPage.qml")
        }
        else{
            if(_cppAppSettings.loadSetting("permanent") === "1"){
                tiuname.text = _cppAppSettings.loadSetting("username")
                tipasswd.text = _cppAppSettings.loadSetting("password")
                _cppAppSettings.writeSetting("permanent", "0")
                _cppAppSettings.writeSetting("username", "")
                _cppAppSettings.writeSetting("password", "")
            }
            laStatus.text = ret
        }
        //root.qmlSignal(tiuname.text, tipasswd.text)
    }

    Dialog {
        id: busyDialog
        modal: true
        closePolicy: "NoAutoClose"
        focus: true
        title: "Please wait..."
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2
        height: 150
        contentHeight: aboutColumn.height
        Column {
            id: aboutColumn
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
                    text: "logging in..."
                    wrapMode: Label.Wrap
                    font.pixelSize: 12
                }
            }
        }
    }



}
