import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: root
    anchors.fill: parent
    header: AppToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u4E09"
            font.pixelSize: Qt.application.font.pixelSize * 1.6

            onClicked: {
                console.log(toolButton.font.styleName)
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent
            ItemDelegate {
                text: qsTr("Fanny Webseite")
                width: parent.width
                onClicked: {
                    stackView.push("WebsitePage.qml")
                    drawer.close()
                }
            }

            ItemDelegate {
                text: qsTr("Speiseplan")
                width: parent.width
                onClicked: {
                    stackView.push("FoodPlanForm.qml")
                    drawer.close()
                }
            }

            ItemDelegate {
                text: qsTr("abmelden")
                width: parent.width
                onClicked: {
                    confirmationDialog.open()
                }
                Dialog {
                    id: confirmationDialog

                    x: (window.width - width) / 2
                    y: (window.height - height) / 2
                    parent: ApplicationWindow.overlay


                    modal: true
                    standardButtons: Dialog.Cancel | Dialog.Ok
                    Column {
                        spacing: 20
                        anchors.fill: parent
                        Label {
                            text: "Möchtest du dich wirklich abmelden?"
                        }
                    }
                    onAccepted: {
                        _cppServerConn.logout()
                        drawer.close()
                        root.StackView.view.push("LoginPage.qml")
                    }
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "HomeForm.qml"
        anchors.fill: parent
    }
}
