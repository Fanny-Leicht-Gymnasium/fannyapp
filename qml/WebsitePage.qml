import QtQuick 2.9
import QtWebView 1.1
import QtQuick.Controls 2.2

import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2

Page {
    id:root

    objectName: "WebsitePage";

    title: qsTr("Fanny Webseite")
    property string icon: "qrc:/graphics/FannyLogo_small.png"

    property string link: "http://www.fanny-leicht.de/j34"

    ProgressBar {
        id: progress
        width: parent.width
        anchors {
            top: parent.top
        }
        //z: Qt.platform.os === "android" ? -1 : 1
        visible: webView.loadProgress < 100
        value: webView.loadProgress === 100 ? 0 : webView.loadProgress / 100
    }

    WebView {
        id: webView
        Keys.onBackPressed: webView.goBack()
        z: 0
        anchors {
            top: webView.loadProgress < 100 ? progress.bottom:parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        url: link
        onLoadingChanged: {
            console.log(url)
            if (loadRequest.errorString)
                console.error(loadRequest.errorString);
        }
    }
}
