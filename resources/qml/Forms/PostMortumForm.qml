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

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

import "../Components"

Page {
    id: root

    property bool locked: false

    signal opened()

    title: "Wo ist der Vertretungsplan?"

    onOpened: {}

    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.margins: 20

        contentHeight: postMortumTextLabel.height

        clip: false

        boundsBehavior: Flickable.StopAtBounds


        ScrollBar.vertical: verticalScrollBar

        Label {
            id: postMortumTextLabel
            width: parent.width
            wrapMode: Text.Wrap
            text: "<h1>Goodbye, old friend ...</h1>
                        <br>Nach mehr als zwei Jahren, hunderten Stunden Arbeit und tausenden Zeilen Code, die ich für die Fannyapp geschrieben habe, stelle ich die Entwicklung nun schweren Herzens ein. Grund dafür ist, dass das Fanny ab diesem Schuljahr (2020/2021) in Sachen Vertretungsplan auf die kommerzielle App \"Untis mobile\" setzt, was den Vertretungsplan in der Fannyapp leider obsolet macht. Allerdings wird die App auch in Zukunft noch den Speiseplan anzeigen können.
                        <br><br>Ich möchte an dieser Stelle nochmals Allen danken, die die Entwicklung der App mit Feedback und Rückmeldungen unterstützt haben, allen voran dem Verein der Freunde, der mir den kostspieligen Apple Entwickler-Account gesponsert hat.<br><br>Bei weiteren Fragen bin ich erreichbar unter <a href='mailto:contact@itsblue.de'>contact@itsblue.de</a>.<br><br>Ich wünsche allen Fanny-SchülerInnen eine genauso schöne Zeit am Fanny, wie ich sie haben durfte :)
                        <br><br>Der Vertretungsplan findet sich ab jetzt <a href='https://herakles.webuntis.com/WebUntis/?school=FannyLGym#/basic/main'>hier bei Untis</a>
                        <br><br>Viele Grüße
                        <br>Dorian Zedler | Entwickler der Fannyapp (und ehemaliger Fanny-Schüler)"
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
    }

    ScrollBar {
        id: verticalScrollBar

        anchors {
            top: flickable.top
            left: flickable.right
            leftMargin: 2
            bottom: flickable.bottom
        }

        interactive: false
    }
}
