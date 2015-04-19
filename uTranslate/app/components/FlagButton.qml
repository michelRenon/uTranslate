/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 0.1

Rectangle {
    anchors.top: parent.top
    width: units.gu(6)

    property string flag : 'fra'

    Image {
        id: imSrc
        source: Qt.resolvedUrl("../graphics/ext/fra.png")
        anchors.fill: parent
    }
    MouseArea {
        anchors.fill: parent
        onClicked: PopupUtils.open(langSelectorComponent, parent)
    }
    function setSource(code, path) {
        flag = code;
        // TEMP DISABLE TO AVOID WARNINGS.
        // WAITING THE REWRITE OF THIS COMPONENT TO HANDLE
        // LANGS AS Text + optional flag
        // imSrc.source = path;
    }
}
