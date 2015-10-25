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
    // anchors.bottom: parent.bottom
    width: units.gu(12)
    color: "white"
    radius: units.gu(3)
    border {
        width: units.gu(0.1)
        color: "darkgray"
    }

    property string lang : 'fr'
    property bool canNotify : false

    /*
     Flags will be shown in a future version

    Image {
        id: imSrc
        anchors.centerIn: parent
        height: parent.height
        width: imSrc.height

        source: Qt.resolvedUrl("../graphics/ext/FR.png")
        visible: parent.lang === 'fr'
    }
    */
    Label {
        id:labelSrc
        anchors.fill: parent

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        text: ""
        clip: true
        fontSize: "small"

        visible: true
    }

    MouseArea {
        anchors.fill: parent

        onPressed:{
            // console.debug("PRESS")
            // bgColor.color = Theme.palette.selected.fieldText
            parent.color = UbuntuColors.orange
            // parent.color = Theme.palette.selected.foregroundText
        }

        onEntered: {
            // console.debug("onEntered")
            parent.color = UbuntuColors.orange
        }

        onCanceled: {
            // console.debug("CANCELED")
            parent.color = "white"
            // parent.color = Theme.palette.normal.baseText
        }

        onReleased: {
            // console.debug("RELEASE")
            // bgColor.color = Theme.palette.normal.fieldText
            parent.color = "white"
            // parent.color = Theme.palette.normal.baseText
        }
        onExited:  {
            // console.debug("onExited")
            parent.color = "white"
        }

        onClicked: {
            // we force a focus change :
            // if the focus is on searchText, then OSK is visible.
            // We need to have the OSK invisible otherwise, the popover will be
            // moved to a specific location. But just after the first clic,
            // the OSK will disappear and the popover will automatically move to another location:
            // very bad user interaction.
            parent.forceActiveFocus()
            // OSK is invisible now, we can open popover.
            // console.debug("clicked mousearea flag")
            // console.debug(parent)
            PopupUtils.open(langSelectorComponent, parent)
        }
    }
    function setSource(code, path) {
        canNotify = false;
        lang = code; // don't want onLangChanged() notification
        canNotify = true;
        var res = utApp.readLang(code);
        // console.debug("setSource : ("+")"+res.name+", "+res.code+", "+res.flag_code);
        labelSrc.text = i18n.tr(res.name)

        // future : handle optional flag :
        // var path="../graphics/flags-iso/"+code+".png";
        // imSrc.source = path;
    }
}
