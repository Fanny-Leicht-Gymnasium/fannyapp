import QtQuick 2.9
import QtQuick.Controls 2.2

ApplicationWindow {
    id: window
    visible: true
    width: 540
    height: 960

    property bool is_error
    property string error

    Timer {
        //runs only one time at applictaion lauch
        id: initTimer
        interval: 1;
        running: true
        repeat: false
        onTriggered: {
            var perm = _cppAppSettings.loadSetting("permanent")
            console.log("checkoldlogin", perm);
            if(perm === "1"){
                console.log("Perm")
                var ret = _cppServerConn.login(_cppAppSettings.loadSetting("username"), _cppAppSettings.loadSetting("password"), true);
                if(ret === "OK"){
                    _cppAppSettings.writeSetting("init", 1);
                    window.is_error = false;
                }
                else {
                    ret = _cppServerConn.checkConn()
                    handleError(ret)
                }
            }
            else {
                stackView.push("qrc:/LoginPage.qml")
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 1000;
        running: true
        repeat: true
        onTriggered: {
            var ret = _cppServerConn.checkConn()
            handleError(ret)
        }
    }

    StackView {
        id: stackView
        initialItem: "MainPage.qml"
        anchors.fill: parent
    }

    function handleError(error_code){
        if(error_code === 200){
            window.is_error = false;
            window.error = "";
        }
        else if(error_code === 401){
            _cppAppSettings.writeSetting("permanent", 0)
            _cppAppSettings.writeSetting("username", "")
            _cppAppSettings.writeSetting("password", "")
            if(["LoginPage"].indexOf(stackView.currentItem.objectName) < 0){
                console.log("switching to login page")
                stackView.push("qrc:/LoginPage.qml");
            }
            window.is_error = true;
            window.error = "Nicht angemeldet!!";
        }
        else if(error_code === 500){
            window.is_error = true;
            window.error = "Interner Server Fehler!";
        }
        else if(error_code === 0){
            window.is_error = true;
            window.error = "Keine Verbindung zum Server!";
        }
        else if(error_code === 404){
            //the testcon function calls a non existent file to be fast, so no error here
            window.is_error = false;
        }
        else if(error_code === 111){
            window.is_error = true;
            window.error = "Unbekannter interner Fehler!";
        }
        else {
            window.is_error = true;
            window.error = "Unbekannter Fehler! ("+error_code+")";
        }
    }
}
