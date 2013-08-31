/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1

ToolbarItems {
    ToolbarButton {
        iconSource: Qt.resolvedUrl("../graphics/toolbarIcon.png")
        text: i18n.tr("No Action")
        
        onTriggered: {
            // label.text = i18n.tr("Toolbar tapped")
            console.debug("No action on toolbar");
        }
    }
}
