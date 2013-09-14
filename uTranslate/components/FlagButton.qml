/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Rectangle {
    anchors.top: parent.top
    width: units.gu(6)

    Image {
        id: imSrc
        source: "../graphics/ext/fra.png"
        anchors.fill: parent
    }
    MouseArea {
        anchors.fill: parent
        onClicked: PopupUtils.open(langSelectorComponent, parent)
    }
    function setSource(path) {
        imSrc.source = path
    }
}