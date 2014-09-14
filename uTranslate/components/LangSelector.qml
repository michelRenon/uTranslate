/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem


Component {

    Popover {
        id: popLangSelector


        property var currentTab: tabs.selectedTab // TODO : check if it's a good way to do

        Column {
            id: containerLayout
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            ListItem.Standard {
                text: i18n.tr("german")
                iconSource: Qt.resolvedUrl("../graphics/ext/deu2.png")
                onClicked: {
                    popLangSelector.doSelectLang('deu')
                }

            }
            ListItem.Standard {
                text: i18n.tr("greek")
                iconSource: Qt.resolvedUrl("../graphics/ext/ell2.png")
                onClicked: {
                    popLangSelector.doSelectLang('ell')
                }

            }
            ListItem.Standard {
                text: i18n.tr("english")
                iconSource: Qt.resolvedUrl("../graphics/ext/eng2.png")
                onClicked: {
                    popLangSelector.doSelectLang('eng')
                }
            }
            ListItem.Standard {
                text: i18n.tr("french")
                iconSource: Qt.resolvedUrl("../graphics/ext/fra2.png")
                onClicked: {
                    popLangSelector.doSelectLang('fra')
                }

            }
            ListItem.Standard {
                text: i18n.tr("italian")
                iconSource: Qt.resolvedUrl("../graphics/ext/ita2.png")
                onClicked: {
                    popLangSelector.doSelectLang('ita')
                }

            }
            ListItem.Standard {
                text: i18n.tr("portugese")
                iconSource: Qt.resolvedUrl("../graphics/ext/por2.png")
                onClicked: {
                    popLangSelector.doSelectLang('por')
                }

            }
            ListItem.Standard {
                text: i18n.tr("spanish")
                iconSource: Qt.resolvedUrl("../graphics/ext/spa2.png")
                onClicked: {
                    popLangSelector.doSelectLang('spa')
                }

            }

        }

        function doSelectLang(lg) {
            // TODO : check if it's the right way to do :
            //
            if (popLangSelector.caller.objectName == "LangDest") {
                currentTab.updateLangDest(lg)
            } else {
                currentTab.updateLang(lg)
            }
            PopupUtils.close(popLangSelector)
        }
    }


}
