/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

ToolbarItems {

    locked: false
    opened: false

    ToolbarButton {
        iconSource: Qt.resolvedUrl("../graphics/settings.png")
        text: i18n.tr("Settings")
        
        onTriggered: {
            // label.text = i18n.tr("Toolbar tapped")
            // console.debug("No action on toolbar");

            // PopupUtils.open(configSheetComponent)

            pageStack.push(settingsPage)
        }
    }
}
