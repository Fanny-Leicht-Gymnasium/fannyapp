import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

ToolButton {
    id: tb

    opacity: enabled ? 1.0 : 0.3

    contentItem: Item {

        Text {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 3
            text: tb.text

            font.pixelSize: tb.height * 0.5
            font.family: iconFont.name
            color: app.style.style.textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    FontLoader {
        id: iconFont
        source: "qrc:/fonts/IconFont.otf"
    }

}
