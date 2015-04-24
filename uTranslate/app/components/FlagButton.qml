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
    width: units.gu(12)

    property string flag : 'fra'

    Image {
        id: imSrc
        source: Qt.resolvedUrl("../graphics/ext/fra.png")
        anchors.fill: parent
    }
    Label {
        id:labelSrc
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: ""
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // we force a focus change :
            // if the focus is on searchText, then OSK is visible.
            // We need to have the OSK invisible otherwise, the popover will be
            // moved to a specific location. But just after the first clic,
            // the OSK will disappear and the popover will automatically move to another location:
            // very bad user interaction.
            parent.forceActiveFocus()
            // OSK is invisible now, we can open popover.
            PopupUtils.open(langSelectorComponent, parent)
        }
    }
    function setSource(code, path) {
        flag = code;
        // TEMP DISABLE TO AVOID WARNINGS.
        // WAITING THE REWRITE OF THIS COMPONENT TO HANDLE
        // LANGS AS Text + optional flag
        var res = utApp.readLang(code);
        console.debug("setSource : "+res.name+", "+res.code+", "+res.flag_code);
        labelSrc.text = i18n.tr(res.name)
        // var path="../graphics/ext/"+code+".png";
        // imSrc.source = path;
    }
}
