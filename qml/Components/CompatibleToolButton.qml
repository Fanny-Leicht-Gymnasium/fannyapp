import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

    Loader {
        id: control

        property QIconSource icon: QIconSource {}

        property int fontPixelSize

        property string text: ""

        signal clicked

        Connections {
            target: icon
            onNameChanged: {
                control.syncProperties()
            }
        }

        onTextChanged: {
            control.syncProperties()
        }

        function syncProperties() {
            if(QtCompatiblityMode) {
                control.sourceComponent = ancientToolButtonCp
                control.item.text = control.text
                control.item.font = control.font

                if(control.fontPixelSize !== undefined) {
                    control.item.font.pixelSize = control.fontPixelSize
                }
            }
            else {
                control.sourceComponent = modernToolButtonCp

                control.item.icon.name = control.icon.name
                control.item.icon.color = control.icon.color

                control.item.icon.width = control.icon.width
                control.item.icon.height = control.icon.height
            }
        }

        onItemChanged: {
            control.syncProperties()
        }

        Component.onCompleted: {
            control.syncProperties()
        }

        Connections {
            target: control.item

            onClicked: {
                control.clicked()
            }
        }

        Component {
            id: ancientToolButtonCp

            ToolButton {
                id: tb

                opacity: enabled ? 1.0 : 0.3

                contentItem: Text {
                    text: tb.text
                    font: tb.font
                    color: app.style.style.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        Component {
            id: modernToolButtonCp

            ToolButton  {
                height: implicitHeight
                width: implicitWidth
            }
        }

    }
